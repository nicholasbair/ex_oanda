# ExOanda Architecture

This document outlines the design decisions and internal architecture of the ExOanda SDK.

## Table of Contents

- [Architecture Overview](#architecture-overview)
- [Project Structure](#project-structure)
- [Key Modules](#key-modules)
- [Code Generation](#code-generation)
- [Data Models](#data-models)
- [Error Handling](#error-handling)

## Architecture Overview

ExOanda is an Elixir SDK for the Oanda Forex API. The SDK uses:

- **Macro-based code generation** to create API modules from a YAML configuration
- **Ecto schemas** for request/response validation and transformation
- **NimbleOptions** for validating keyword list parameters
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

### Parameter Validation with NimbleOptions

Keyword list parameters (query params, filters, etc.) are validated using [NimbleOptions](https://hexdocs.pm/nimble_options/). The parameter schema is defined in `config.yml` and converted to a NimbleOptions schema at compile time.

```yaml
# In config.yml
parameters:
  - name: "instrument"
    type: "string"
    required: false
    doc: "Filter by instrument name"
  - name: "count"
    type: "integer"
    required: false
    default: 50
```

This generates validation that checks types, required fields, and provides helpful error messages:

```elixir
# Valid usage
ExOanda.Trades.list(conn, account_id, instrument: "EUR_USD", count: 100)

# Invalid - returns {:error, %ValidationError{}}
ExOanda.Trades.list(conn, account_id, count: "not_an_integer")
```

The two layers of validation are:
1. **NimbleOptions** - Validates the keyword list parameters passed to functions
2. **Ecto changesets** - Validates request body structs for POST/PUT/PATCH requests

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
