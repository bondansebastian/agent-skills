# Validation — Laravel 7.x Guidelines
Source: https://laravel.com/docs/7.x/validation

---

## Always Use Form Requests for Controller Validation

Form Requests extract validation logic out of controllers — keeping controllers thin
and validation reusable and testable.

```bash
php artisan make:request StorePostRequest
php artisan make:request UpdatePostRequest
```

```php
// app/Http/Requests/StorePostRequest.php
class StorePostRequest extends FormRequest
{
    /**
     * Determine if the user is authorized to make this request.
     */
    public function authorize(): bool
    {
        // Return true to allow all authenticated users, OR check a policy:
        return $this->user()->can('create', Post::class);
    }

    /**
     * Get the validation rules that apply to the request.
     */
    public function rules(): array
    {
        return [
            'title'      => ['required', 'string', 'max:255'],
            'body'       => ['required', 'string'],
            'category_id'=> ['required', 'integer', 'exists:categories,id'],
            'tags'       => ['nullable', 'array'],
            'tags.*'     => ['integer', 'exists:tags,id'],
            'published_at'=> ['nullable', 'date'],
        ];
    }

    /**
     * Custom human-readable attribute names.
     */
    public function attributes(): array
    {
        return [
            'category_id' => 'category',
        ];
    }

    /**
     * Custom error messages.
     */
    public function messages(): array
    {
        return [
            'title.required' => 'A post title is required.',
        ];
    }
}
```

In the controller, type-hint the Form Request — validation and auth run automatically:

```php
public function store(StorePostRequest $request)
{
    // Only runs if validation passes
    // $request->validated() returns only the validated fields — ALWAYS use this
    $post = Post::create($request->validated());
    return redirect()->route('posts.show', $post);
}
```

### Always Use `$request->validated()` — Never `$request->all()`

```php
// BAD — passes all input, potential mass-assignment vulnerability
Post::create($request->all());

// GOOD — only validated, declared fields pass through
Post::create($request->validated());

// Also fine — only specific keys from validated data
Post::create($request->safe()->only(['title', 'body']));
```

---

## Quick Inline Validation (Simple Endpoints Only)

Use `$request->validate()` only for simple, one-off cases where a Form Request is overkill:

```php
public function store(Request $request)
{
    $validated = $request->validate([
        'title' => ['required', 'max:255'],
        'email' => ['required', 'email', 'unique:users'],
    ]);
    
    // $validated only contains the fields listed above
    User::create($validated);
}
```

---

## Common Validation Rules Reference

```php
// Presence
'field' => ['required']
'field' => ['nullable']          // allow null/empty
'field' => ['sometimes']         // only validate if present

// Strings
'field' => ['string', 'min:3', 'max:255']
'field' => ['email']
'field' => ['url']
'field' => ['alpha', 'alpha_num', 'alpha_dash']
'field' => ['regex:/^[A-Z]+$/']

// Numbers
'field' => ['integer', 'min:0', 'max:100']
'field' => ['numeric', 'between:1,1000']
'field' => ['digits:4']

// Database
'field' => ['exists:table,column']    // must exist in DB
'field' => ['unique:table,column']    // must be unique

// Unique with ignore (for update scenarios)
'email' => ['unique:users,email,' . $this->user->id]
// Or with Rule object (preferred):
'email' => [Rule::unique('users')->ignore($this->user->id)]

// Files
'photo' => ['file', 'image', 'mimes:jpg,png', 'max:2048']  // max in KB

// Arrays
'tags'   => ['array'],
'tags.*' => ['integer', 'exists:tags,id']  // validate each array item

// Dates
'start_date' => ['date', 'after:today']
'end_date'   => ['date', 'after:start_date']

// Conditional
'discount' => [Rule::requiredIf($request->has_discount)]
```

---

## Displaying Errors in Blade

```blade
{{-- Check for any errors --}}
@if ($errors->any())
    <div class="alert alert-danger">
        <ul>
            @foreach ($errors->all() as $error)
                <li>{{ $error }}</li>
            @endforeach
        </ul>
    </div>
@endif

{{-- Per-field error display --}}
<input type="text" name="title" value="{{ old('title') }}"
       class="@error('title') is-invalid @enderror">
@error('title')
    <div class="invalid-feedback">{{ $message }}</div>
@enderror
```

Always use `old('field')` to repopulate form fields after a validation failure.

---

## Custom Validation Rules

Prefer Rule objects for reusable custom rules:

```bash
php artisan make:rule Uppercase
```

```php
class Uppercase implements Rule
{
    public function passes($attribute, $value): bool
    {
        return strtoupper($value) === $value;
    }

    public function message(): string
    {
        return 'The :attribute must be uppercase.';
    }
}

// Usage
'name' => ['required', new Uppercase]
```
