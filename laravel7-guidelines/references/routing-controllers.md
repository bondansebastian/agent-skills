# Routing & Controllers — Laravel 7.x Guidelines
Source: https://laravel.com/docs/7.x/routing | https://laravel.com/docs/7.x/controllers | https://laravel.com/docs/7.x/middleware

---

## Routing Best Practices

### Use Named Routes — Always

```php
// GOOD — named routes for URL generation, avoid hard-coding URLs
Route::get('/flights/{flight}', 'FlightController@show')->name('flights.show');

// In views/controllers
route('flights.show', $flight)   // correct
'/flights/' . $flight->id        // BAD — hard-coded
```

### Route Files — Use the Right One

| File | Purpose | Middleware Group |
|---|---|---|
| `routes/web.php` | Browser-facing (HTML, sessions) | `web` (session, CSRF, cookies) |
| `routes/api.php` | Stateless API endpoints | `api` (rate-limiting, no sessions) |
| `routes/console.php` | Artisan command closures | — |
| `routes/channels.php` | Broadcasting channels | — |

### Group Related Routes

```php
Route::prefix('admin')
    ->name('admin.')
    ->namespace('Admin')
    ->middleware(['auth', 'role:admin'])
    ->group(function () {
        Route::resource('users', 'UserController');
        Route::resource('posts', 'PostController');
    });
```

### Use Resource Controllers for CRUD

```php
// Generates all 7 RESTful routes
Route::resource('photos', 'PhotoController');

// Only need some actions
Route::resource('photos', 'PhotoController')->only(['index', 'show']);
Route::resource('photos', 'PhotoController')->except(['destroy']);
```

The 7 resource actions: `index`, `create`, `store`, `show`, `edit`, `update`, `destroy`

### Route Model Binding — Implicit (Use It!)

```php
// Automatically resolves {flight} to a Flight model, 404 if not found
Route::get('/flights/{flight}', 'FlightController@show');

public function show(Flight $flight)  // type-hint to the model
{
    return view('flights.show', compact('flight'));
}
```

Custom resolution key (e.g. slug instead of id):

```php
// In Flight model
public function getRouteKeyName(): string
{
    return 'slug';
}
```

### Rate Limiting

```php
// Apply built-in throttle middleware
Route::middleware('throttle:60,1')->group(function () {
    Route::get('/api/users', 'UserController@index');
});
```

---

## Controller Best Practices

### Keep Controllers Thin — Single Responsibility

Controllers should:
- Receive the HTTP request
- Delegate to services / models
- Return a response

Controllers should NOT:
- Contain business logic
- Query the database directly (beyond simple Eloquent calls)
- Perform complex data transformations

```php
// GOOD — thin controller
public function store(StoreOrderRequest $request, OrderService $orderService)
{
    $order = $orderService->create($request->validated());
    return redirect()->route('orders.show', $order)->with('success', 'Order placed!');
}

// BAD — fat controller
public function store(Request $request)
{
    // 50 lines of business logic here...
}
```

### Resource Controller Standard Structure

```php
class PostController extends Controller
{
    public function index()   { /* list */ }
    public function create()  { /* show form */ }
    public function store(StorePostRequest $request) { /* save */ }
    public function show(Post $post) { /* single item */ }
    public function edit(Post $post) { /* show edit form */ }
    public function update(UpdatePostRequest $request, Post $post) { /* update */ }
    public function destroy(Post $post) { /* delete */ }
}
```

### Single Action Controllers — For Complex Actions

```php
php artisan make:controller ShowDashboard --invokable

class ShowDashboard extends Controller
{
    public function __invoke(Request $request)
    {
        return view('dashboard');
    }
}

Route::get('/dashboard', 'ShowDashboard');
```

### Controller Middleware — Declare in Constructor

```php
public function __construct()
{
    $this->middleware('auth');
    $this->middleware('log')->only('index');
    $this->middleware('subscribed')->except('index', 'show');
}
```

### Dependency Injection in Controllers

```php
// Constructor injection for shared dependencies
public function __construct(
    private UserRepository $users,
    private MailService $mail
) {}

// Method injection for request-specific dependencies
public function store(StoreUserRequest $request, UserService $service)
{
    $user = $service->create($request->validated());
    // ...
}
```

---

## Middleware Best Practices

### Create Focused, Single-Purpose Middleware

```php
php artisan make:middleware EnsureEmailIsVerified

public function handle($request, Closure $next)
{
    if (! $request->user()->hasVerifiedEmail()) {
        return redirect()->route('verification.notice');
    }
    return $next($request);
}
```

### Register Global vs. Route Middleware

```php
// app/Http/Kernel.php

// $middleware — runs on every request
protected $middleware = [/* ... */];

// $middlewareGroups — applied to web/api route groups
protected $middlewareGroups = [
    'web'  => [/* ... */],
    'api'  => [/* ... */],
];

// $routeMiddleware — applied per-route with a key
protected $routeMiddleware = [
    'auth'       => \App\Http\Middleware\Authenticate::class,
    'role'       => \App\Http\Middleware\CheckRole::class,
    'throttle'   => \Illuminate\Routing\Middleware\ThrottleRequests::class,
];
```

### Terminable Middleware — For Post-Response Tasks

```php
public function terminate($request, $response): void
{
    // Runs after response is sent — good for logging, analytics
}
```

---

## CORS

Configure CORS in `config/cors.php` (Laravel 7 ships with built-in CORS handling via `HandleCors` middleware). Do not write custom CORS middleware unless you have a very specific need.
