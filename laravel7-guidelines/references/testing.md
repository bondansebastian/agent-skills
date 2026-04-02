# Testing — Laravel 7.x Guidelines
Source: https://laravel.com/docs/7.x/testing | https://laravel.com/docs/7.x/http-tests | https://laravel.com/docs/7.x/database-testing

---

## Test Setup

```bash
php artisan make:test PostTest           # Feature test (in tests/Feature/)
php artisan make:test PostUnitTest --unit  # Unit test (in tests/Unit/)
```

Use `phpunit.xml` database config — prefer SQLite in-memory for speed:

```xml
<!-- phpunit.xml -->
<env name="DB_CONNECTION" value="sqlite"/>
<env name="DB_DATABASE" value=":memory:"/>
<env name="CACHE_DRIVER" value="array"/>
<env name="QUEUE_CONNECTION" value="sync"/>
<env name="MAIL_MAILER" value="array"/>
```

---

## Feature Tests — HTTP Testing

Test the full request lifecycle (routing → controller → response):

```php
class PostTest extends TestCase
{
    use RefreshDatabase;  // Rolls back DB after each test

    public function test_authenticated_user_can_create_post(): void
    {
        $user = factory(User::class)->create();

        $response = $this->actingAs($user)->post(route('posts.store'), [
            'title' => 'Test Post',
            'body'  => 'This is the body.',
        ]);

        $response->assertRedirect(route('posts.index'));
        $response->assertSessionHas('success');
        $this->assertDatabaseHas('posts', ['title' => 'Test Post']);
    }

    public function test_guest_cannot_create_post(): void
    {
        $response = $this->post(route('posts.store'), ['title' => 'Test']);
        $response->assertRedirect(route('login'));
    }

    public function test_post_validation_fails_without_title(): void
    {
        $user = factory(User::class)->create();
        $response = $this->actingAs($user)->post(route('posts.store'), []);
        $response->assertSessionHasErrors(['title']);
    }
}
```

### Common HTTP Test Assertions

```php
$response->assertStatus(200);
$response->assertOk();             // 200
$response->assertCreated();        // 201
$response->assertNoContent();      // 204
$response->assertNotFound();       // 404
$response->assertForbidden();      // 403
$response->assertUnauthorized();   // 401

$response->assertRedirect($url);
$response->assertSessionHas('key', 'value');
$response->assertSessionHasErrors(['field']);
$response->assertViewIs('posts.index');
$response->assertViewHas('posts');
$response->assertSee('Hello World');
$response->assertDontSee('Error');

// JSON API responses
$response->assertJson(['key' => 'value']);
$response->assertJsonStructure(['data' => ['id', 'title']]);
$response->assertJsonCount(3, 'data');
```

---

## Database Testing

```php
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Foundation\Testing\DatabaseTransactions;

// RefreshDatabase — re-migrates (slower, use for full suite)
// DatabaseTransactions — wraps each test in a transaction (faster)

// Assert DB state
$this->assertDatabaseHas('posts', ['title' => 'Hello']);
$this->assertDatabaseMissing('posts', ['title' => 'Deleted Post']);
$this->assertDatabaseCount('posts', 5);
$this->assertDeleted($post);  // checks soft-deleted or hard-deleted
```

---

## Mocking

### Mocking Facades

```php
// Prevent actual mail from sending
Mail::fake();
// ... trigger code that sends mail ...
Mail::assertSent(WelcomeMail::class, function ($mail) use ($user) {
    return $mail->hasTo($user->email);
});
Mail::assertNotSent(InvoiceMail::class);

// Queue
Queue::fake();
Queue::assertPushed(SendInvoiceJob::class);
Queue::assertNotPushed(SomeOtherJob::class);

// Events
Event::fake();
Event::assertDispatched(OrderShipped::class);

// Storage
Storage::fake('s3');
Storage::disk('s3')->assertExists('photos/avatar.jpg');
```

### Mocking Dependencies with Mockery

```php
$mock = $this->mock(OrderService::class, function ($mock) {
    $mock->shouldReceive('process')
         ->once()
         ->with(Mockery::type(Order::class))
         ->andReturn(true);
});
```

---

## Best Practices

- Test **one thing** per test method — keep tests focused
- Use descriptive names: `test_authenticated_user_can_update_own_post`
- Use `RefreshDatabase` for feature tests; factories for test data
- Mock external services (email, payment, storage) — don't hit real APIs in tests
- Write tests for happy paths AND failure/edge cases
- Run `php artisan test` (or `vendor/bin/phpunit`) before every commit
- Target high coverage on critical paths (auth, payments, core business logic)
