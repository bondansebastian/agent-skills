# Queues, Jobs & Events — Laravel 8.x

Source: https://laravel.com/docs/8.x/queues
        https://laravel.com/docs/8.x/events

---

## Jobs

```bash
php artisan make:job ProcessArticle
```

```php
<?php

namespace App\Jobs;

use App\Models\Article;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;

class ProcessArticle implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    public int $tries = 3;        // Retry attempts
    public int $timeout = 60;     // Seconds before job times out

    public function __construct(public Article $article) {}

    public function handle(): void
    {
        // Long-running task here
    }
}

// Dispatch
ProcessArticle::dispatch($article);
ProcessArticle::dispatch($article)->delay(now()->addMinutes(10));
ProcessArticle::dispatchIf($article->isReady(), $article);
```

---

## Job Batching (New in Laravel 8.x)

```php
use Illuminate\Support\Facades\Bus;

$batch = Bus::batch([
    new ProcessPodcast($podcast1),
    new ProcessPodcast($podcast2),
    new ProcessPodcast($podcast3),
])
->then(function (Batch $batch) {
    // All jobs completed successfully
})
->catch(function (Batch $batch, Throwable $e) {
    // First batch job failure detected
})
->finally(function (Batch $batch) {
    // Batch has finished executing (success or failure)
})
->onQueue('processing')
->dispatch();

// Check batch progress
$batch->id;
$batch->totalJobs;
$batch->processedJobs();
$batch->progress();
$batch->finished();
```

Run migration first: `php artisan queue:batches-table && php artisan migrate`

---

## Events & Listeners

```bash
php artisan make:event ArticlePublished
php artisan make:listener SendPublishNotification --event=ArticlePublished
```

```php
// Dispatch
event(new ArticlePublished($article));
// Or on model:
ArticlePublished::dispatch($article);
```

Register in `EventServiceProvider`:
```php
protected $listen = [
    ArticlePublished::class => [
        SendPublishNotification::class,
        UpdateSearchIndex::class,
    ],
];
```

**Queueable listeners:**
```php
class SendPublishNotification implements ShouldQueue
{
    public function handle(ArticlePublished $event): void
    {
        // Runs async on the queue
    }
}
```

---

## Queue Best Practices

- Always implement `ShouldQueue` for long-running tasks (emails, file processing, API calls).
- Set `$tries` and `$timeout` on every job.
- Use `SerializesModels` — pass the model, not the full object dump.
- Use `onQueue('emails')` to separate queue channels.
- Monitor queues with Laravel Horizon (Redis) or Supervisor (database/SQS).
