# Database, Migrations & Query Builder — Laravel 7.x Guidelines
Source: https://laravel.com/docs/7.x/migrations | https://laravel.com/docs/7.x/queries | https://laravel.com/docs/7.x/database

---

## Migrations Best Practices

### Always Generate with Artisan

```bash
php artisan make:migration create_posts_table
php artisan make:migration add_published_at_to_posts_table
php artisan make:migration create_post_tag_table  # pivot table
```

### Standard Migration Structure

```php
public function up(): void
{
    Schema::create('posts', function (Blueprint $table) {
        $table->id();                          // BIGINT unsigned, auto-increment PK
        $table->foreignId('user_id')           // unsigned BIGINT (FK column)
              ->constrained()                  // adds FK constraint to users.id
              ->onDelete('cascade');
        $table->string('title');
        $table->string('slug')->unique();
        $table->text('body');
        $table->boolean('is_published')->default(false);
        $table->timestamp('published_at')->nullable();
        $table->timestamps();                  // created_at + updated_at
        $table->softDeletes();                 // deleted_at (when using SoftDeletes trait)
    });
}

public function down(): void
{
    Schema::dropIfExists('posts');
}
```

### Column Types Reference

```php
$table->id();                     // alias for bigIncrements('id')
$table->uuid('id');               // UUID PK
$table->string('email', 100);     // VARCHAR(100)
$table->text('body');             // TEXT
$table->longText('content');      // LONGTEXT
$table->integer('votes');
$table->bigInteger('price');
$table->decimal('amount', 8, 2);  // DECIMAL(8,2)
$table->boolean('active');
$table->json('options');
$table->timestamp('verified_at')->nullable();
$table->date('birth_date');
$table->enum('status', ['draft', 'published', 'archived']);

// Foreign keys (Laravel 7 style)
$table->foreignId('category_id')->constrained()->onDelete('cascade');
// Explicit FK definition
$table->unsignedBigInteger('user_id');
$table->foreign('user_id')->references('id')->on('users')->onDelete('cascade');
```

### Pivot Tables — Alphabetical Order, No `id`

```php
Schema::create('post_tag', function (Blueprint $table) {
    // Alphabetical: post before tag
    $table->foreignId('post_id')->constrained()->onDelete('cascade');
    $table->foreignId('tag_id')->constrained()->onDelete('cascade');
    $table->primary(['post_id', 'tag_id']);
    // Add extra columns if needed: $table->boolean('is_featured')->default(false);
});
```

### Modifying Columns — Use `doctrine/dbal`

```bash
composer require doctrine/dbal
```

```php
// Add column to existing table
$table->string('phone')->nullable()->after('email');

// Modify existing
$table->string('name', 100)->change();

// Rename column
$table->renameColumn('from', 'to');

// Drop column
$table->dropColumn('votes');
```

### Never Edit Old Migrations in Production

Always create a new migration to alter a table. Only edit a migration if it has never been run in production.

---

## Query Builder Best Practices

### Always Use Bindings — Never String Interpolation

```php
// BAD — SQL injection risk
DB::select("SELECT * FROM users WHERE email = '$email'");

// GOOD — parameterized
DB::select('SELECT * FROM users WHERE email = ?', [$email]);

// BEST — use Eloquent or query builder
User::where('email', $email)->first();
```

### Prefer Eloquent Over Raw Query Builder

Use raw query builder only when Eloquent won't suffice (complex reports, performance-critical aggregates).

```php
// Acceptable use of query builder
$results = DB::table('orders')
    ->join('users', 'users.id', '=', 'orders.user_id')
    ->select('users.name', DB::raw('COUNT(orders.id) as order_count'))
    ->groupBy('users.id')
    ->orderByDesc('order_count')
    ->limit(10)
    ->get();
```

### Transactions — Wrap Multi-Step DB Operations

```php
// Automatic rollback on exception
DB::transaction(function () use ($data) {
    $order = Order::create($data['order']);
    $order->items()->createMany($data['items']);
    $order->invoice()->create();
});

// Manual transaction
DB::beginTransaction();
try {
    // ...
    DB::commit();
} catch (\Exception $e) {
    DB::rollBack();
    throw $e;
}
```

### Pagination — Always Paginate Large Datasets

```php
// Simple paginator (no total count — faster)
$posts = Post::simplePaginate(15);

// Full paginator with total count
$posts = Post::paginate(15);

// In Blade
{{ $posts->links() }}
```

### Database Seeding

```php
// Factory definition
$factory->define(User::class, function (Faker $faker) {
    return [
        'name'     => $faker->name,
        'email'    => $faker->unique()->safeEmail,
        'password' => bcrypt('password'),
    ];
});

// Create in seeder
factory(User::class, 50)->create();
factory(Post::class, 100)->create([
    'user_id' => factory(User::class),
]);
```
