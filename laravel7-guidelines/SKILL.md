---
name: laravel7-guidelines
description: >
  Coding guidelines and best practices for Laravel 7.x projects, sourced from the
  official Laravel 7.x documentation (https://laravel.com/docs/7.x).
  Use this skill whenever the user asks about Laravel 7.x code, architecture, patterns,
  conventions, or best practices — including questions about Eloquent ORM, routing,
  controllers, middleware, validation, migrations, security, Blade templates, queues,
  testing, or any other Laravel 7.x topic. Also trigger for code reviews, project setup
  questions, debugging Laravel issues, or when the user says things like "how do I do X
  in Laravel", "is this the right way in Laravel 7", or "write me a Laravel controller/
  model/migration". If Laravel is mentioned at all, check this skill.
---

# Laravel 7.x Coding Guidelines & Best Practices

Source of truth: https://laravel.com/docs/7.x  
PHP requirement: **>= 7.2.5**

---

## Quick Reference — When to Read Which File

| Topic | Reference File |
|---|---|
| Eloquent ORM, Models, Relationships | `references/eloquent.md` |
| Routing, Controllers, Middleware | `references/routing-controllers.md` |
| Validation, Form Requests | `references/validation.md` |
| Database, Migrations, Query Builder | `references/database.md` |
| Security, Auth, Hashing, CSRF | `references/security.md` |
| Blade, Views, Frontend | `references/frontend.md` |
| Testing | `references/testing.md` |

Read the relevant reference file(s) before writing or reviewing Laravel 7.x code.  
For multi-topic tasks (e.g. "build a full CRUD feature"), read **all** relevant files.

---

## Core Architectural Rules (Always Apply)

### 1. Directory & Namespace Conventions

- Models live in `app/` (e.g. `App\User`, `App\Post`)
- Controllers in `app/Http/Controllers/`
- Form Requests in `app/Http/Requests/`
- Middleware in `app/Http/Middleware/`
- Events/Listeners in `app/Events/` and `app/Listeners/`
- Jobs in `app/Jobs/`
- Policies in `app/Policies/`
- Service Providers in `app/Providers/`
- All class names use **PascalCase**, methods use **camelCase**, DB columns/routes use **snake_case**

### 2. Configuration

- All config lives in `config/` — never hard-code credentials or environment-specific values
- Use `env()` **only inside config files**, never directly in app code
- Access config values via `config('app.name')` in application code
- Sensitive values must go in `.env` and be listed in `.env.example`

### 3. Service Container & Dependency Injection

- Bind interfaces to implementations in a Service Provider, not scattered throughout the app
- Type-hint dependencies in constructors and controller methods — let the container resolve them
- Avoid `app()` helper / `App::make()` except in Service Providers or bootstrapping code
- Prefer constructor injection over method injection for shared dependencies

### 4. Service Providers

- Register bindings in `register()`, bootstrap logic in `boot()`
- Never perform heavy work (DB queries, HTTP calls) in `register()`
- Defer providers when possible using `$defer = true` to improve performance

### 5. Facades vs. Contracts

- Facades are fine for application code; prefer Contracts (interfaces) in packages for testability
- Avoid creating your own Facades — use the container or constructor injection instead

---

## Naming Conventions Cheatsheet

| Element | Convention | Example |
|---|---|---|
| Model | PascalCase singular | `Flight`, `UserProfile` |
| Controller | PascalCase + `Controller` | `FlightController` |
| Migration | snake_case with timestamp | `2020_01_01_create_flights_table` |
| Table | snake_case plural | `flights`, `user_profiles` |
| Column | snake_case | `first_name`, `created_at` |
| Route | kebab-case URI | `/user-profiles/{id}` |
| Named route | dot notation | `flights.index`, `admin.users.show` |
| Blade view | dot notation, snake_case | `flights.index`, `partials.nav` |
| Event | PascalCase, past tense noun | `OrderShipped`, `UserRegistered` |
| Job | PascalCase, imperative verb | `SendInvoiceEmail`, `ProcessPayment` |
| Policy | PascalCase + `Policy` | `FlightPolicy` |

---

## Anti-Patterns to Avoid

- **Fat controllers** — business logic belongs in dedicated service classes or the model layer
- **Logic in routes** — closures in `routes/web.php` are fine only for trivial cases; use controllers
- **Raw SQL without bindings** — always use query builder or Eloquent to prevent SQL injection
- **`$request->all()` in mass assignment** — always specify `$fillable` or use `$request->validated()`
- **Validation in models** — validate in Form Requests or controllers, not Eloquent models
- **Business logic in Blade** — views should only render; delegate logic to controllers/view composers
- **Ignoring `.env.example`** — every new env variable must be added to `.env.example`
- **Skipping migrations** — never modify tables manually; always create a new migration

---

## Artisan Commands Reference

```bash
# Code generation
php artisan make:model Post -mrc          # Model + migration + resource controller
php artisan make:request StorePostRequest  # Form Request
php artisan make:middleware EnsureAdmin
php artisan make:policy PostPolicy --model=Post
php artisan make:job SendWelcomeEmail
php artisan make:event OrderShipped
php artisan make:observer PostObserver --model=Post

# Database
php artisan migrate
php artisan migrate:fresh --seed          # Drop all + re-migrate + seed (dev only)
php artisan db:seed

# Optimization (production)
php artisan config:cache
php artisan route:cache
php artisan view:cache
php artisan optimize
```
