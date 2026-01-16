# Contributing to ExOanda

Thank you for your interest in contributing to ExOanda! This document provides an overview of the SDK architecture and guidance for making contributions.

## Table of Contents

- [Architecture Overview](#architecture-overview)
- [Project Structure](#project-structure)
- [Key Modules](#key-modules)
- [Code Generation](#code-generation)
- [Data Models](#data-models)
- [Error Handling](#error-handling)
- [Testing](#testing)
- [Common Contribution Scenarios](#common-contribution-scenarios)

## Architecture Overview

ExOanda is an Elixir SDK for the Oanda Forex API. The SDK uses:

- **Macro-based code generation** to create API interface modules from a YAML configuration
- **Ecto schemas** for request/response validation and transformation
- **Req** as the HTTP client with telemetry integration
- **Polymorphic embeds** for variant data types (different order types, transaction types, etc.)

## Project Structure

```
lib/
├── ex_oanda.ex              # Main entry point (uses code generator)
├── connection.ex            # Connection struct for API credentials
├── streaming/               # Real-time price and transaction streaming
├── code_gen/                # Code generation machinery
│   ├── code_generator.ex    # Macro that generates API modules from config.yml
│   └── config.ex            # Configuration loader
├── models/
│   ├── definitions/         # Core data structures (accounts, orders, trades, etc.)
│   ├── request/             # Request payload schemas with validation
│   └── response/            # Response payload schemas
└── util/
    ├── api.ex               # HTTP request/response handling
    ├── transform.ex         # JSON to struct transformation
    ├── telemetry.ex         # Telemetry instrumentation
    └── *_error.ex           # Error type definitions

config.yml                   # API configuration (defines all endpoints)
```

## Key Modules

### API Layer

| Module | Purpose |
|--------|---------|
| `ExOanda.Connection` | Holds API credentials, server URLs, and options |
| `ExOanda.API` | HTTP request execution, authentication, response handling |
| `ExOanda.Streaming` | Real-time price and transaction streaming |

### Generated Interface Modules

These modules are auto-generated at compile time from `config.yml`:

- `ExOanda.Accounts` - Account management
- `ExOanda.Orders` - Order creation and management
- `ExOanda.Trades` - Trade operations
- `ExOanda.Positions` - Position management
- `ExOanda.Pricing` - Current prices and candles
- `ExOanda.Instruments` - Historical candle data
- `ExOanda.Transactions` - Transaction history

### Data Transformation

| Module | Purpose |
|--------|---------|
| `ExOanda.Transform` | Converts JSON responses to typed Ecto structs |
| `ExOanda.Type.Atom` | Custom Ecto type for atom fields |
| `ExOanda.CloseoutUnits` | Custom Ecto type for union types |

## Code Generation

The SDK uses compile-time code generation to avoid boilerplate. Here's how it works:

1. **`config.yml`** defines all API endpoints with their HTTP methods, paths, arguments, parameters, and response schemas

2. **`ExOanda.CodeGenerator`** reads the config at compile time and generates:
   - Function definitions with proper specs
   - Parameter validation using NimbleOptions
   - Request body validation using Ecto changesets
   - Both regular (`function/2`) and bang (`function!/2`) variants

### Example config.yml entry

```yaml
interfaces:
  - module_name: "Accounts"
    functions:
      - function_name: "list"
        http_method: "GET"
        path: "/accounts"
        response_schema: "ListAccounts"
      - function_name: "find"
        http_method: "GET"
        path: "/accounts/:account_id"
        response_schema: "FindAccount"
        arguments:
          - name: "account_id"
            type: "string"
```

## Data Models

Models use Ecto schemas with `TypedEctoSchema` for automatic type spec generation.

### Model Categories

- **Definitions** (`lib/models/definitions/`) - Core data structures like `Account`, `Order`, `Trade`
- **Request** (`lib/models/request/`) - Schemas for POST/PUT/PATCH payloads with validation
- **Response** (`lib/models/response/`) - Schemas for API responses

### Example Model

```elixir
defmodule ExOanda.Account do
  use TypedEctoSchema
  import Ecto.Changeset

  @primary_key false
  typed_embedded_schema do
    field(:id, :string)
    field(:alias, :string)
    field(:currency, :string)
    field(:balance, :float)
    # ... more fields
  end

  def changeset(struct \\ %__MODULE__{}, params) do
    struct
    |> cast(params, [:id, :alias, :currency, :balance])
  end
end
```

### Polymorphic Embeds

For variant types (e.g., different order types), the SDK uses `polymorphic_embed`:

```elixir
polymorphic_embeds_one(:order,
  types: [
    market: ExOanda.MarketOrder,
    limit: ExOanda.LimitOrder,
    stop: ExOanda.StopOrder
  ],
  on_type_not_found: :raise,
  on_replace: :update
)
```

## Error Handling

The SDK defines four error types:

| Error | When Raised |
|-------|-------------|
| `ExOanda.ValidationError` | Parameter or request body validation fails |
| `ExOanda.APIError` | Oanda API returns non-2xx status |
| `ExOanda.TransportError` | Network errors (timeout, connection refused) |
| `ExOanda.DecodeError` | JSON parsing fails |

### Return Pattern

All functions return `{:ok, result}` or `{:error, reason}`. Bang variants raise exceptions instead.

```elixir
# Tuple return
{:ok, response} = ExOanda.Accounts.list(conn)
{:error, %ValidationError{}} = ExOanda.Orders.create(conn, account_id, invalid_order)

# Bang variant (raises on error)
response = ExOanda.Accounts.list!(conn)
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

## Development Commands

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
