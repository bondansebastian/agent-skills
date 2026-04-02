# Security — Laravel 8.x

Source: https://laravel.com/docs/8.x/authorization
        https://laravel.com/docs/8.x/sanctum
        https://laravel.com/docs/8.x/csrf

---

## Authorization: Policies & Gates

```bash
php artisan make:policy ArticlePolicy --model=Article
```

```php
class ArticlePolicy
{
    public function update(User $user, Article $article): bool
    {
        return $user->id === $article->user_id;
    }

    public function delete(User $user, Article $article): bool
    {
        return $user->id === $article->user_id || $user->isAdmin();
    }
}
```

**Use in controllers:**
```php
public function update(UpdateArticleRequest $request, Article $article)
{
    $this->authorize('update', $article); // Throws 403 if unauthorized
    $article->update($request->validated());
}
```

**Use in Blade:**
```blade
@can('update', $article)
    <a href="{{ route('articles.edit', $article) }}">Edit</a>
@endcan
```

---

## Sanctum (API Tokens for SPAs / Mobile)

```php
// Install: composer require laravel/sanctum
// Add HasApiTokens trait to User model
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable;
}

// Issue token
$token = $user->createToken('token-name')->plainTextToken;

// Protect routes
Route::middleware('auth:sanctum')->get('/user', fn (Request $request) => $request->user());
```

---

## CSRF Protection

- All `POST`, `PUT`, `PATCH`, `DELETE` routes in `web.php` require a CSRF token.
- Always add `@csrf` to Blade forms.
- API routes (`api.php`) are excluded from CSRF by default.

```blade
<form method="POST" action="{{ route('articles.store') }}">
    @csrf
    {{-- fields --}}
</form>
```

---

## Mass Assignment Protection

```php
// ✅ Always define $fillable or $guarded
protected $fillable = ['title', 'body']; // Whitelist approach (preferred)
// OR
protected $guarded = ['id']; // Blacklist approach

// ✅ Always use validated() not all()
Article::create($request->validated());
```

---

## Rate Limiting

```php
// In RouteServiceProvider::configureRateLimiting()
RateLimiter::for('api', function (Request $request) {
    return Limit::perMinute(60)->by($request->user()?->id ?: $request->ip());
});

// Apply to routes
Route::middleware(['throttle:api'])->group(function () { ... });
```

---

## Input Sanitization & SQL Injection

- Always use Eloquent or the Query Builder — never raw string interpolation in queries.
- If using `DB::raw()`, bind values with `?` or named bindings.

```php
// ✅ Safe
DB::select('SELECT * FROM users WHERE email = ?', [$email]);

// ❌ Dangerous
DB::select("SELECT * FROM users WHERE email = '{$email}'");
```
