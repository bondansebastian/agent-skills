---
name: laravel8-guidelines
description: >
  Coding guidelines, best practices, and conventions for Laravel 8.x projects. Use this skill
  whenever the user asks about Laravel 8 code structure, architecture, naming conventions, routing,
  controllers, Eloquent models, migrations, validation, service providers, factories, testing, or
  any Laravel 8.x-specific feature. Trigger on questions like "how should I structure my Laravel
  app", "is this the right way to do X in Laravel", "write me a Laravel controller/model/migration",
  "what's the best practice for validation in Laravel 8", or any time the user shares Laravel code
  for review. Also trigger for general PHP/Laravel patterns if the project is on version 8.x.
---

# Laravel 8.x – Coding Guidelines & Best Practices

Source of truth: https://laravel.com/docs/8.x

For deep-dives on specific topics, read the relevant reference file in `references/`:
- `references/eloquent.md` — Eloquent ORM, relationships, scopes, accessors/mutators
- `references/testing.md` — Feature/unit tests, factories, HTTP tests
- `references/security.md` — Auth, authorization, CSRF, SQL injection
- `references/queues-jobs.md` — Queues, job batching (new in 8.x), events

---

## 1. Project Structure

Laravel 8.x introduced the `app/Models/` directory as the default home for Eloquent models.

```
app/
├── Console/
├── Exceptions/
├── Http/
│   ├── Controllers/
│   ├── Middleware/
│   └── Requests/         ← Form Request classes live here
├── Models/               ← All Eloquent models (new default in 8.x)
├── Policies/
├── Providers/
├── Rules/                ← Custom validation rules
└── Services/             ← Business logic (not a Laravel default, but best practice)
database/
├── factories/            ← Class-based factories (new in 8.x) — namespace: Database\Factories
├── migrations/
└── seeders/              ← namespace: Database\Seeders
routes/
├── web.php               ← Web routes (session, CSRF, cookies)
├── api.php               ← Stateless API routes
├── console.php
└── channels.php
```

**Rules:**
- Keep `app/` lean — push business logic into `Services/`, `Actions/`, or dedicated domain folders.
- Never put logic directly in `routes/web.php` or `routes/api.php`; use controllers.
- Configuration belongs in `config/`, never hard-coded.

---

## 2. Naming Conventions

| What | Convention | Good | Bad |
|---|---|---|---|
| Controller | Singular, PascalCase | `ArticleController` | `ArticlesController` |
| Model | Singular, PascalCase | `User`, `BlogPost` | `Users`, `blog_post` |
| Migration | snake_case, descriptive | `create_blog_posts_table` | `posts`, `addCol` |
| Table | Plural, snake_case | `blog_posts` | `BlogPost`, `blogposts` |
| Primary key | `id` (default) | `id` | `post_id` (on model itself) |
| Foreign key | `{model}_id` | `user_id` | `userId`, `user` |
| Route name | snake_case with dot notation | `users.show_active` | `show-active-users` |
| Route URI | Plural, kebab-case | `/blog-posts` | `/blogPost`, `/blog_post` |
| Method (controller) | camelCase | `showActive()` | `show_active()` |
| hasOne / belongsTo | Singular | `articleComment()` | `articleComments()` |
| hasMany / others | Plural | `articleComments()` | `articleComment()` |
| Factory | `{Model}Factory` | `UserFactory` | `UsersFactory` |

---

## 3. Routes

**Use named routes and resource controllers whenever possible.**

```php
// ✅ Good — class-based callable syntax (Laravel 8.x default, $namespace is null)
use App\Http\Controllers\ArticleController;

Route::get('/articles', [ArticleController::class, 'index'])->name('articles.index');
Route::resource('articles', ArticleController::class);
Route::apiResource('articles', ArticleController::class); // API (no create/edit)

// ✅ Good — route model binding
Route::get('/articles/{article}', [ArticleController::class, 'show']);

// ❌ Bad — string-based controller syntax (deprecated default in 8.x)
Route::get('/articles', 'ArticleController@index');

// ❌ Bad — logic in routes
Route::get('/articles', function () {
    return Article::all(); // belongs in a controller
});
```

**Group and protect routes with middleware:**
```php
Route::middleware(['auth'])->group(function () {
    Route::resource('articles', ArticleController::class)->except(['index', 'show']);
});
```

**Always name routes** to avoid hard-coded URLs:
```php
// Generate URL: route('articles.show', $article)
// Redirect:     redirect()->route('articles.index')
```

---

## 4. Controllers

Follow the **Single Responsibility Principle** — one controller per resource, one responsibility per method.

```php
<?php

namespace App\Http\Controllers;

use App\Http\Requests\StoreArticleRequest;
use App\Models\Article;

class ArticleController extends Controller
{
    // ✅ Inject the model via route model binding, not manual querying
    public function show(Article $article)
    {
        return view('articles.show', compact('article'));
    }

    // ✅ Use Form Requests for validation (not inline $request->validate())
    public function store(StoreArticleRequest $request)
    {
        $article = Article::create($request->validated());
        return redirect()->route('articles.show', $article);
    }
}
```

**Invokable (single-action) controllers** for one-off actions:
```php
// php artisan make:controller PublishArticleController --invokable
class PublishArticleController extends Controller
{
    public function __invoke(Article $article)
    {
        $article->publish();
        return redirect()->route('articles.show', $article);
    }
}
// Route:
Route::post('/articles/{article}/publish', PublishArticleController::class);
```

**Don'ts:**
- ❌ No business logic in controllers — push to service classes or model methods.
- ❌ No direct DB queries in controllers — use Eloquent models or repositories.
- ❌ Don't call `$request->validate()` inline for complex rules — use Form Requests.

---

## 5. Eloquent Models

```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Article extends Model
{
    use HasFactory, SoftDeletes;

    // ✅ Always define $fillable (or $guarded = []) — never leave both empty
    protected $fillable = ['title', 'body', 'user_id', 'published_at'];

    // ✅ Use $casts to handle type conversion declaratively
    protected $casts = [
        'published_at' => 'datetime',
        'is_featured'  => 'boolean',
        'metadata'     => 'array',
    ];

    // ✅ Relationships are methods, named per conventions
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function comments(): HasMany
    {
        return $this->hasMany(Comment::class);
    }

    // ✅ Use local scopes for reusable query constraints
    public function scopePublished(Builder $query): Builder
    {
        return $query->whereNotNull('published_at');
    }

    // ✅ Use accessor/mutator (Laravel 8 style) for computed attributes
    public function getExcerptAttribute(): string
    {
        return Str::limit($this->body, 150);
    }
}
```

**Query best practices:**
```php
// ✅ Eager-load to prevent N+1
$articles = Article::with(['user', 'comments'])->published()->get();

// ✅ Use firstOrFail() / findOrFail() — auto 404 on missing record
$article = Article::findOrFail($id);

// ✅ Use updateOrCreate / firstOrCreate for upsert patterns
Article::updateOrCreate(['slug' => $slug], ['title' => $title]);

// ❌ Bad — N+1 query problem
foreach (Article::all() as $article) {
    echo $article->user->name; // Fires 1 query per article
}
```

---

## 6. Migrations

```php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

// ✅ Anonymous migration class (best practice in 8.x+)
return new class extends Migration
{
    public function up(): void
    {
        Schema::create('articles', function (Blueprint $table) {
            $table->id();                           // Auto-incrementing BIGINT PK
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->string('title');
            $table->string('slug')->unique();
            $table->longText('body');
            $table->timestamp('published_at')->nullable();
            $table->timestamps();                   // created_at, updated_at
            $table->softDeletes();                  // deleted_at
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('articles');
    }
};
```

**Rules:**
- Always write a proper `down()` method.
- Use `foreignId('user_id')->constrained()` — it auto-resolves the foreign table.
- Never modify or delete existing migration files — create new ones instead.
- Use `php artisan migrate:fresh --seed` only in local/testing environments.
- Prefer `->nullable()` over missing columns for optional fields.
- Add indexes on columns used in `WHERE` and `ORDER BY` clauses.

---

## 7. Validation — Form Requests

Move all validation out of controllers into dedicated Form Request classes.

```bash
php artisan make:request StoreArticleRequest
```

```php
<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StoreArticleRequest extends FormRequest
{
    // ✅ Authorization logic belongs here, not in the controller
    public function authorize(): bool
    {
        return $this->user()->can('create', Article::class);
    }

    public function rules(): array
    {
        return [
            'title'        => ['required', 'string', 'max:255'],
            'body'         => ['required', 'string'],
            'published_at' => ['nullable', 'date'],
            'tags'         => ['sometimes', 'array'],
            'tags.*'       => ['exists:tags,id'],
        ];
    }

    // ✅ Only pass validated data to the model
    // In the controller: Article::create($request->validated());
}
```

**Always use `$request->validated()`**, not `$request->all()`, when mass-assigning to models.

---

## 8. Class-Based Factories (New in 8.x)

Laravel 8 completely rewrote factories as class-based. Namespace: `Database\Factories`.

```php
<?php

namespace Database\Factories;

use App\Models\Article;
use Illuminate\Database\Eloquent\Factories\Factory;

class ArticleFactory extends Factory
{
    protected $model = Article::class;

    public function definition(): array
    {
        return [
            'user_id'      => \App\Models\User::factory(),  // ✅ Factory relationships
            'title'        => $this->faker->sentence(),
            'slug'         => $this->faker->unique()->slug(),
            'body'         => $this->faker->paragraphs(3, true),
            'published_at' => now(),
        ];
    }

    // ✅ State methods for specific scenarios
    public function draft(): static
    {
        return $this->state(['published_at' => null]);
    }
}
```

Usage (model must `use HasFactory`):
```php
Article::factory()->count(5)->create();
Article::factory()->draft()->for(User::factory())->create();
```

---

## 9. Service Providers

Use `register()` to bind into the container, `boot()` for bootstrapping (view composers, model observers, Gates).

```php
public function register(): void
{
    // Bind interface to implementation
    $this->app->bind(ArticleRepositoryInterface::class, ArticleRepository::class);
}

public function boot(): void
{
    // Register model observers
    Article::observe(ArticleObserver::class);

    // Register authorization policies
    Gate::policy(Article::class, ArticlePolicy::class);
}
```

**Rules:**
- Never put HTTP logic or route definitions in service providers (use route files).
- Keep `AppServiceProvider` for app-wide bootstrapping; create dedicated providers for distinct concerns (e.g., `AuthServiceProvider`, `EventServiceProvider`).

---

## 10. Laravel 8.x-Specific Features

### Job Batching
```php
use Illuminate\Support\Facades\Bus;

$batch = Bus::batch([
    new ProcessPodcast($podcast1),
    new ProcessPodcast($podcast2),
])->then(function (Batch $batch) {
    // All jobs completed successfully
})->catch(function (Batch $batch, Throwable $e) {
    // First batch job failure detected
})->dispatch();
```

### Route `->missing()` Callback
```php
Route::get('/articles/{article:slug}', [ArticleController::class, 'show'])
    ->missing(fn () => redirect()->route('articles.index'));
```

### `->value()` on Eloquent
```php
// ✅ Fetch a single column without hydrating a model
$email = User::where('id', 1)->value('email');
```

### `firstOrNew`, `firstOrCreate`, `updateOrCreate`
Prefer these over manually checking existence + saving.

---

## 11. Security Checklist

- ✅ Always use `$request->validated()` — never `$request->all()` for mass assignment.
- ✅ Define `$fillable` on every model (or `$guarded = ['id']` at minimum).
- ✅ Use Laravel's built-in CSRF protection — `@csrf` in all web forms.
- ✅ Use Policies and Gates for authorization — never inline role checks.
- ✅ Never pass raw user input to `ignore()` in unique validation rules (SQL injection risk).
- ✅ Use `.env` for secrets — never commit API keys or passwords.
- ✅ Rate-limit sensitive routes: `Route::middleware(['throttle:6,1'])->...`.
- ✅ Hash passwords with `bcrypt()` or `Hash::make()`, never `md5()`/`sha1()`.

---

## 12. Anti-Patterns to Avoid

| Anti-pattern | Why bad | Fix |
|---|---|---|
| Logic in routes file | Hard to test, unstructured | Move to controllers |
| `DB::` raw queries everywhere | Bypasses Eloquent, SQL injection risk | Use Eloquent / Query Builder |
| `$request->all()` on mass-assign | Can expose unintended fields | Use `$request->validated()` |
| No eager loading | N+1 query problem | Use `with()` / `load()` |
| Inline validation in controllers | Clutters controllers | Use Form Request classes |
| Giant controller methods | Violates SRP | Extract to Service classes |
| Hard-coded URLs | Breaks on route changes | Use `route()` helper |
| Missing `down()` in migrations | Can't roll back | Always implement `down()` |
| Secrets in code | Security risk | Use `.env` + `config()` |

---

## Reference Files

Read these when you need deeper detail:
- `references/eloquent.md` — Relationships, accessors/mutators, scopes, observers
- `references/testing.md` — PHPUnit, feature tests, Pest, HTTP tests, mocking
- `references/security.md` — Sanctum/Passport, Gates, Policies, CSRF, XSS
- `references/queues-jobs.md` — Jobs, batching, events, broadcasting
