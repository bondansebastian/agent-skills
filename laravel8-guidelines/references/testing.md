# Testing — Laravel 8.x

Source: https://laravel.com/docs/8.x/testing
        https://laravel.com/docs/8.x/http-tests
        https://laravel.com/docs/8.x/database-testing

---

## Test Types

- **Unit tests** — `tests/Unit/` — test a single class in isolation (no DB, no HTTP).
- **Feature tests** — `tests/Feature/` — test HTTP endpoints, database interactions, full request/response cycle.

---

## Feature Test Example

```php
<?php

namespace Tests\Feature;

use App\Models\Article;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class ArticleTest extends TestCase
{
    use RefreshDatabase; // ✅ Rolls back DB after each test

    public function test_authenticated_user_can_create_article(): void
    {
        $user = User::factory()->create();

        $response = $this->actingAs($user)
            ->postJson('/api/articles', [
                'title' => 'Hello World',
                'body'  => 'Some content here',
            ]);

        $response->assertStatus(201)
                 ->assertJsonPath('data.title', 'Hello World');

        $this->assertDatabaseHas('articles', ['title' => 'Hello World']);
    }

    public function test_guest_cannot_create_article(): void
    {
        $this->postJson('/api/articles', ['title' => 'Test'])
             ->assertUnauthorized();
    }
}
```

---

## Factory Usage in Tests

```php
// Create persisted model
$user = User::factory()->create();

// Make (not persisted)
$article = Article::factory()->make(['title' => 'Custom Title']);

// Create with relationships
$user = User::factory()
    ->has(Article::factory()->count(3))
    ->create();

// Create with state
$draft = Article::factory()->draft()->create();
```

---

## HTTP Assertion Helpers

```php
$response->assertOk();                          // 200
$response->assertCreated();                     // 201
$response->assertNoContent();                   // 204
$response->assertNotFound();                    // 404
$response->assertUnauthorized();                // 401
$response->assertForbidden();                   // 403
$response->assertRedirect(route('articles.index'));
$response->assertJson(['status' => 'ok']);
$response->assertJsonPath('data.0.title', 'Hello');
$response->assertJsonStructure(['data' => [['id', 'title', 'body']]]);
$response->assertViewIs('articles.show');
$response->assertSee('Hello World');
```

---

## Database Assertions

```php
$this->assertDatabaseHas('articles', ['title' => 'Hello']);
$this->assertDatabaseMissing('articles', ['title' => 'Deleted']);
$this->assertSoftDeleted('articles', ['id' => $article->id]);
```

---

## Mocking

```php
// Mock a facade
Storage::fake('public');
Mail::fake();
Event::fake();
Queue::fake();
Notification::fake();

// After action, assert:
Queue::assertPushed(ProcessArticleJob::class);
Mail::assertSent(WelcomeEmail::class, fn ($mail) => $mail->hasTo('user@example.com'));
```
