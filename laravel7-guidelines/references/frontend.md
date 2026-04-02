# Blade Templates & Frontend — Laravel 7.x Guidelines
Source: https://laravel.com/docs/7.x/blade | https://laravel.com/docs/7.x/mix

---

## Blade Best Practices

### Always Escape Output — Use `{{ }}` Not `{!! !!}`

```blade
{{-- SAFE — HTML escaped --}}
{{ $user->name }}
{{ $post->title }}

{{-- DANGEROUS — only for trusted, pre-sanitized HTML --}}
{!! $post->renderedHtml !!}
```

Only use `{!! !!}` for HTML you've explicitly sanitized (e.g. output from a Markdown parser).

### Layouts — Use `@extends` / `@section` / `@yield`

```blade
{{-- resources/views/layouts/app.blade.php --}}
<!DOCTYPE html>
<html>
<head>
    <title>@yield('title', config('app.name'))</title>
    @stack('styles')
</head>
<body>
    @include('partials.nav')

    <main>
        @yield('content')
    </main>

    @include('partials.footer')
    @stack('scripts')
</body>
</html>
```

```blade
{{-- resources/views/posts/show.blade.php --}}
@extends('layouts.app')

@section('title', $post->title . ' | ' . config('app.name'))

@section('content')
    <h1>{{ $post->title }}</h1>
    <p>{{ $post->body }}</p>
@endsection

@push('scripts')
    <script src="{{ asset('js/post.js') }}"></script>
@endpush
```

### Blade Components (Laravel 7 feature — Preferred for Reusable UI)

```bash
php artisan make:component Alert
# Creates: app/View/Components/Alert.php + resources/views/components/alert.blade.php
```

```php
// app/View/Components/Alert.php
class Alert extends Component
{
    public function __construct(
        public string $type = 'info',
        public string $message = ''
    ) {}

    public function render()
    {
        return view('components.alert');
    }
}
```

```blade
{{-- resources/views/components/alert.blade.php --}}
<div class="alert alert-{{ $type }}">
    {{ $message }}
</div>

{{-- Usage anywhere --}}
<x-alert type="success" message="Saved successfully!" />
<x-alert type="danger" :message="$errorMessage" />
```

### Conditionals and Loops

```blade
@if ($user->isAdmin())
    <span>Admin</span>
@elseif ($user->isModerator())
    <span>Moderator</span>
@else
    <span>User</span>
@endif

@unless ($user->isAdmin())
    <p>Regular user</p>
@endunless

@forelse ($posts as $post)
    <li>{{ $post->title }}</li>
@empty
    <li>No posts found.</li>
@endforelse

@foreach ($comments as $comment)
    @continue($comment->is_spam)
    <p>{{ $comment->body }}</p>
    @break($loop->iteration === 10)
@endforeach
```

### The `$loop` Variable in Loops

```blade
@foreach ($posts as $post)
    @if ($loop->first) <ul> @endif
    <li>{{ $loop->iteration }}/{{ $loop->count }}: {{ $post->title }}</li>
    @if ($loop->last) </ul> @endif
@endforeach
```

### CSRF, Method Spoofing, Auth in Blade

```blade
{{-- Forms --}}
<form method="POST" action="{{ route('posts.store') }}">
    @csrf
</form>

<form method="POST" action="{{ route('posts.update', $post) }}">
    @csrf
    @method('PUT')  {{-- spoofs the method --}}
</form>

{{-- Auth checks --}}
@auth
    Welcome, {{ auth()->user()->name }}
@endauth

@guest
    <a href="{{ route('login') }}">Login</a>
@endguest
```

---

## Asset Compilation — Laravel Mix

Always compile assets via Mix, never reference raw files in `resources/`:

```bash
npm install
npm run dev       # development build
npm run watch     # watch for changes
npm run prod      # production (minified + versioned)
```

```javascript
// webpack.mix.js
const mix = require('laravel-mix');

mix.js('resources/js/app.js', 'public/js')
   .sass('resources/sass/app.scss', 'public/css')
   .version();  // cache-busting in production
```

```blade
{{-- Always use mix() helper for versioned assets --}}
<link rel="stylesheet" href="{{ mix('css/app.css') }}">
<script src="{{ mix('js/app.js') }}"></script>
```

---

## View Sharing — Use View Composers, Not Controllers

```php
// In AppServiceProvider::boot() or a dedicated ViewServiceProvider
View::composer('partials.nav', function ($view) {
    $view->with('categories', Category::all());
});

// Wildcard — share with all views
View::composer('*', function ($view) {
    $view->with('cartCount', auth()->user()?->cartItemCount() ?? 0);
});
```
