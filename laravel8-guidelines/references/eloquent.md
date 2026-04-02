# Eloquent Deep-Dive — Laravel 8.x

Source: https://laravel.com/docs/8.x/eloquent
        https://laravel.com/docs/8.x/eloquent-relationships
        https://laravel.com/docs/8.x/eloquent-mutators

---

## Relationships

```php
// One-to-One
public function phone(): HasOne
{
    return $this->hasOne(Phone::class);
}

// One-to-Many
public function posts(): HasMany
{
    return $this->hasMany(Post::class);
}

// Belongs To (inverse)
public function user(): BelongsTo
{
    return $this->belongsTo(User::class);
}

// Many-to-Many
public function roles(): BelongsToMany
{
    return $this->belongsToMany(Role::class)
        ->withPivot('expires_at')
        ->withTimestamps();
}

// Has Many Through
public function deployments(): HasManyThrough
{
    return $this->hasManyThrough(Deployment::class, Environment::class);
}

// Polymorphic
public function comments(): MorphMany
{
    return $this->morphMany(Comment::class, 'commentable');
}
```

## Scopes

```php
// Local scope (chain as ->active() on query)
public function scopeActive(Builder $query): Builder
{
    return $query->where('active', true);
}

// Global scope — applies to all queries for this model
protected static function booted(): void
{
    static::addGlobalScope('active', fn (Builder $b) => $b->where('active', true));
}
```

## Accessors & Mutators (Laravel 8 style)

```php
// Old style (still works in 8.x):
public function getFullNameAttribute(): string
{
    return "{$this->first_name} {$this->last_name}";
}

// Access: $user->full_name
```

## Observers

```php
// php artisan make:observer ArticleObserver --model=Article
class ArticleObserver
{
    public function creating(Article $article): void
    {
        $article->slug = Str::slug($article->title);
    }

    public function deleting(Article $article): void
    {
        $article->comments()->delete();
    }
}

// Register in AppServiceProvider::boot()
Article::observe(ArticleObserver::class);
```

## Soft Deletes

```php
use Illuminate\Database\Eloquent\SoftDeletes;

class Article extends Model
{
    use SoftDeletes;
    // Migration: $table->softDeletes();
}

// Queries automatically exclude soft-deleted records.
// Include trashed:
Article::withTrashed()->get();
Article::onlyTrashed()->get();
$article->restore();
$article->forceDelete();
```

## Useful Eloquent Methods

```php
// Single column value (no model hydration)
$name = User::where('id', 1)->value('name');

// Pluck a column into a collection
$emails = User::pluck('email', 'id'); // [id => email]

// Chunk for large datasets — prevent memory exhaustion
User::chunk(200, function ($users) {
    foreach ($users as $user) { /* ... */ }
});

// Count without hydrating
$count = Article::published()->count();

// firstOrCreate / updateOrCreate
$user = User::firstOrCreate(
    ['email' => $email],
    ['name' => $name, 'password' => Hash::make('password')]
);
```
