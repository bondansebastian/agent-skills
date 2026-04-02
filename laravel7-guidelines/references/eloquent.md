# Eloquent ORM — Laravel 7.x Guidelines
Source: https://laravel.com/docs/7.x/eloquent | https://laravel.com/docs/7.x/eloquent-relationships

---

## Model Definition Best Practices

### Always Declare `$fillable` or `$guarded`

Never leave both unset — it's a mass-assignment vulnerability.

```php
// GOOD — explicit whitelist (preferred)
protected $fillable = ['title', 'body', 'user_id'];

// ACCEPTABLE — explicit blacklist (be careful)
protected $guarded = ['id'];

// BAD — completely open
protected $guarded = [];  // only OK if you fully trust all input
```

### Always Define `$casts`

Cast your attributes to appropriate PHP types to avoid string bugs:

```php
protected $casts = [
    'is_published' => 'boolean',
    'options'      => 'array',
    'published_at' => 'datetime',
    'price'        => 'decimal:2',
];
```

### Use `$hidden` to Protect Sensitive Data

```php
protected $hidden = ['password', 'remember_token', 'api_token'];
```

### Model Conventions (follow or explicitly override)

- Table name: snake_case plural of class name (`Flight` → `flights`)
- Primary key: `id` (integer, auto-increment)
- Timestamps: `created_at` / `updated_at` (managed automatically)

```php
// Overriding conventions when needed
protected $table      = 'my_flights';
protected $primaryKey = 'flight_id';
protected $keyType    = 'string';   // for UUID keys
public $incrementing  = false;      // for non-integer PKs
public $timestamps    = false;      // if table has no timestamps
```

---

## Querying Best Practices

### Avoid N+1 — Always Eager Load Relationships

```php
// BAD — N+1 queries
$posts = Post::all();
foreach ($posts as $post) {
    echo $post->author->name; // 1 query per post
}

// GOOD — 2 queries total
$posts = Post::with('author')->get();

// Nested eager loading
$posts = Post::with('author.profile', 'comments.user')->get();
```

### Use `select()` to Limit Columns

```php
// Only fetch what you need
User::select('id', 'name', 'email')->get();
```

### Chunk Large Datasets

```php
// Process 200 records at a time — never load all at once
User::chunk(200, function ($users) {
    foreach ($users as $user) {
        // process...
    }
});
```

### Use `findOrFail()` and `firstOrFail()` in Controllers

```php
// Returns 404 automatically — no manual check needed
$flight = Flight::findOrFail($id);
$post   = Post::where('slug', $slug)->firstOrFail();
```

### Use Query Scopes for Reusable Conditions

```php
// In the model
public function scopePublished(Builder $query): Builder
{
    return $query->where('is_published', true);
}

public function scopeOfType(Builder $query, string $type): Builder
{
    return $query->where('type', $type);
}

// Usage
Post::published()->ofType('article')->get();
```

---

## Relationships

### Define Both Sides of a Relationship

```php
// Post model
public function comments(): HasMany
{
    return $this->hasMany(Comment::class);
}

// Comment model — define the inverse
public function post(): BelongsTo
{
    return $this->belongsTo(Post::class);
}
```

### Use `withCount()` Instead of Loading Full Collections for Counts

```php
// GOOD — adds comments_count attribute, no loading all comments
Post::withCount('comments')->get();
```

### Polymorphic Relationships — Name Consistently

Use `{model}_type` and `{model}_id` for morph columns:

```php
// Migration
$table->morphs('commentable'); // creates commentable_type + commentable_id
```

---

## Soft Deletes

```php
use Illuminate\Database\Eloquent\SoftDeletes;

class Post extends Model
{
    use SoftDeletes;
}
```

- Soft-deleted records are excluded from queries automatically
- Use `withTrashed()` to include them, `onlyTrashed()` for just deleted
- Add `$table->softDeletes()` to the migration

---

## Observers — Use for Model Event Side Effects

```php
// Better than putting logic in model boot()
class UserObserver
{
    public function created(User $user): void
    {
        // send welcome email, etc.
    }
}

// Register in AppServiceProvider::boot()
User::observe(UserObserver::class);
```

---

## Eloquent API Resources

Always transform model output for APIs — never return raw models from controllers:

```php
// Create resource
php artisan make:resource PostResource
php artisan make:resource PostCollection

// In resource
public function toArray($request): array
{
    return [
        'id'         => $this->id,
        'title'      => $this->title,
        'author'     => new UserResource($this->whenLoaded('author')),
        'created_at' => $this->created_at->toISOString(),
    ];
}

// In controller
return new PostResource($post);
return PostResource::collection(Post::paginate());
```
