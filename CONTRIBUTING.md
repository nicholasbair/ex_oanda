# Contributing to ExOanda

Thank you for your interest in contributing to ExOanda! This guide will help you get started with development and making contributions.

## Understanding the Architecture

Before contributing, we recommend reading [ARCHITECTURE.md](ARCHITECTURE.md) to understand how the SDK is designed. It covers:
- Code generation from `config.yml`
- Data model organization
- Error handling patterns
- Key modules and their purposes

## Table of Contents

- [Development Setup](#development-setup)
- [Testing](#testing)
- [Common Contribution Scenarios](#common-contribution-scenarios)
- [Key Files Reference](#key-files-reference)
- [Questions?](#questions)

## Development Setup

```bash
# Install dependencies
mix deps.get

# Compile
mix compile

# Run tests
mix test

# Run tests with coverage
mix coveralls

# Run static analysis
mix dialyzer

# Run code style checks
mix credo

# Generate documentation
mix docs
```

## Testing

### Test Structure

```
test/
├── models/
│   ├── request/      # Request validation tests
│   ├── response/     # Response parsing tests
│   └── definitions/  # Schema definition tests
├── support/          # Test utilities
├── api_test.exs
├── streaming_test.exs
└── ...
```

### Running Tests

```bash
# Run all tests
mix test

# Run with coverage
mix coveralls

# Run specific test file
mix test test/streaming_test.exs
```

### Testing Patterns

- Use `Bypass` for HTTP mocking
- Most tests run with `async: true`
- Test both valid and invalid inputs for changesets

## Common Contribution Scenarios

### Adding a New API Endpoint

1. **Update `config.yml`** with the new function definition:

```yaml
- function_name: "new_endpoint"
  http_method: "POST"
  path: "/accounts/:account_id/new-endpoint"
  request_schema: "NewEndpointRequest"   # if POST/PUT/PATCH
  response_schema: "NewEndpointResponse"
  arguments:
    - name: "account_id"
      type: "string"
  parameters:
    - name: "some_param"
      type: "string"
      required: false
```

2. **Create request schema** (if needed) in `lib/models/request/`:

```elixir
defmodule ExOanda.Request.NewEndpointRequest do
  use TypedEctoSchema
  import Ecto.Changeset

  @primary_key false
  typed_embedded_schema do
    field(:some_field, :string)
  end

  def changeset(struct \\ %__MODULE__{}, params) do
    struct
    |> cast(params, [:some_field])
    |> validate_required([:some_field])
  end
end
```

3. **Create response schema** in `lib/models/response/`:

```elixir
defmodule ExOanda.Response.NewEndpointResponse do
  use TypedEctoSchema
  import Ecto.Changeset

  @primary_key false
  typed_embedded_schema do
    field(:result, :string)
  end

  def changeset(struct \\ %__MODULE__{}, params) do
    cast(struct, params, [:result])
  end
end
```

4. **Add tests** in `test/models/request/` and `test/models/response/`

5. **Recompile**: `mix compile`

### Adding a New Data Model

1. Create the schema in `lib/models/definitions/category/`
2. Define fields using `typed_embedded_schema`
3. Implement `changeset/2` for validation
4. Add tests in `test/models/definitions/`
5. Reference in request/response schemas as needed

### Fixing a Bug in Response Parsing

1. Check `lib/util/transform.ex` for transformation logic
2. Check the relevant response schema in `lib/models/response/`
3. Add a failing test that reproduces the bug
4. Fix the schema or transformation logic
5. Verify the test passes

### Modifying Code Generation

1. Study `lib/code_gen/code_generator.ex`
2. Understand the macro expansion with `Macro.expand/2`
3. Make changes carefully - this affects all generated modules
4. Run the full test suite to verify nothing breaks

## Key Files Reference

| File | When to Edit |
|------|--------------|
| `config.yml` | Adding/modifying API endpoints |
| `lib/code_gen/code_generator.ex` | Changing how functions are generated |
| `lib/util/transform.ex` | Fixing JSON parsing issues |
| `lib/util/api.ex` | Changing HTTP handling |
| `lib/streaming/streaming.ex` | Streaming functionality |
| `lib/models/definitions/` | Core data structures |
| `lib/models/request/` | Request validation |
| `lib/models/response/` | Response parsing |

## Questions?

If you have questions about the codebase or need guidance on a contribution, feel free to open an issue for discussion.
