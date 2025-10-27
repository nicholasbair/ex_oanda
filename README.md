Unofficial Elixir SDK for the Oanda API.

[![Hex.pm version](https://img.shields.io/hexpm/v/ex_oanda)](https://hex.pm/packages/ex_oanda)
[![Latest HexDocs](https://img.shields.io/badge/docs-latest-green.svg?style=flat-square)](https://hexdocs.pm/ex_oanda/)
[![Elixir CI Status](https://github.com/nicholasbair/ex_oanda/workflows/Elixir%20CI/badge.svg)](https://github.com/nicholasbair/ex_oanda/actions?query=workflow%3A%22Elixir+CI%22)

## Notes

### TODO / Known Issues
- Not all schemas have been validated against Oanda's live API.
  - Note: this SDK is used for my own algo trading, but not every schema has been exercised with real data. For example, I haven't been margin called, so that schema hasn't been officially tested.

### *Forex Trading Risk Disclaimer*

Trading foreign exchange (forex) on margin carries a high level of risk and may not be suitable for all investors. The leveraged nature of forex trading can amplify both profits and losses, potentially resulting in the loss of all invested capital. Before engaging in forex trading, please carefully consider your investment objectives, experience level, and risk tolerance.

This SDK is provided "as-is," without any warranty of any kind, either expressed or implied, including but not limited to the implied warranties of merchantability, fitness for a particular purpose, or non-infringement. The use of this SDK is at your own risk, and we make no guarantees regarding its accuracy, reliability, or suitability for any specific trading strategy or purpose. Users are responsible for their own trading decisions and should seek independent financial advice if necessary.

## Installation
```elixir
def deps do
  [
    {:ex_oanda, "~> 0.1.1"}
  ]
end
```

## General Usage
1. Connection is a struct that stores your Oanda API credentials.
```elixir
conn =
  %ExOanda.Connection{
    token: "1234", # Configured in the Oanda API
    api_server: "https://api-fxpractice.oanda.com/v3",
    stream_server: "https://stream-fxpractice.oanda.com/v3",
    options: [], # Passed to Req (HTTP client)
    telemetry: %ExOanda.Telemetry{
      enabled: true, # Defaults to false
      use_default_logger: true, # Defaults to false
      options: []
    }
  }
```

Options from `ExOanda.Connection` are passed directly to [Req](https://hexdocs.pm/req/Req.html) and can be used to override the default behavior of the HTTP client. You can find a complete list of options [here](https://hexdocs.pm/req/Req.html#new/1). The most relevant Req defaults are listed below:
```elixir
[
  retry: :safe_transient,
  cache: false,
  compress_body: false,
  compressed: true, # ask server to return compressed responses
  receive_timeout: 15_000, # socket receive timeout
  pool_timeout: 5000 # pool checkout timeout
]
```

When using options, _do not_ override the value for `decode_body`, in most cases, the SDK is relying on Req to decode the response via Jason.

2. Nearly all functions support returning an ok/error tuple or raising an exception, for example:
```elixir
conn = %ExOanda.Connection{token: "1234"}

# Returns {:ok, result} or {:error, reason}
{:ok, response} = ExOanda.Accounts.first(conn)

# Returns result or raises an exception
response = ExOanda.Accounts.first!(conn)
```

3. Where supported, queries and filters can be passed as keyword list and are validated by NimbleOptions:
```elixir
# Correct filter
> ExOanda.Accounts.list_changes(
    %ExOanda.Connection{token: "1234"},
    "account_id",
    since_transaction_id: "5678"
  )
{:ok, %ExOanda.Response{...}}

# Incorrect filter
> ExOanda.Accounts.list_changes(
    %ExOanda.Connection{token: "1234"},
    "account_id",
    since_transaction_id: 1234
  )
{:error, %ExOanda.ValidationError{}}
```

4. [Ecto](https://hex.pm/packages/ecto) is used to validate request payloads and transform response payloads from Oanda into structs.

## Error Handling

Most functions are available in two forms: non-bang (e.g., `list/2`) and bang (e.g., `list!/2`). The non-bang functions return `{:ok, result}` or `{:error, reason}` tuples, while bang functions return the result or raise an exception.

| Scenario | Non-bang (no `!`) | Bang (`!`) |
|---|---|---|
| 2xx success | `{:ok, response_struct}` | `response_struct` |
| Non-2xx HTTP status (Oanda API error) | `{:error, response_struct}` | raises `ExOanda.APIError` |
| Transport/network error (timeouts, connection, HTTP adapter) | `{:error, %ExOanda.TransportError{}}` | raises `ExOanda.TransportError` |
| Parameter validation failure (NimbleOptions) | `{:error, %ExOanda.ValidationError{validation_type: :parameter_validation}}` | raises `ExOanda.ValidationError` |
| Request body validation failure (Ecto changeset) | `{:error, %ExOanda.ValidationError{validation_type: :request_body_validation}}` | raises `ExOanda.ValidationError` |
| JSON decode error (e.g., streaming) | `{:error, %ExOanda.DecodeError{}}` | raises `ExOanda.DecodeError` |

Notes:
- **`response_struct`**: For non-2xx HTTP responses returned by Oanda, the SDK parses and returns a structured response under the appropriate `ExOanda.Response.*` schema.
- Bang variants internally call the non-bang functions and raise on `{:error, reason}` according to the mapping above.
- The top-level `ExOanda.Response` struct includes the underlying HTTP status as an atom in `status` (see `ExOanda.Response.t()`) and Oanda's `request_id` when available (from the `requestid` response header).

## Telemetry

ExOanda supports telemetry instrumentation using [ReqTelemetry](https://hexdocs.pm/req_telemetry/ReqTelemetry.html) to monitor HTTP requests and responses. This is useful for debugging, monitoring API performance, and integrating with observability tools.

### Basic Usage

Enable telemetry by setting the `telemetry` field in your connection:

```elixir
conn = %ExOanda.Connection{
  token: "1234",
  telemetry: %ExOanda.Telemetry{
    enabled: true,
    use_default_logger: true
  }
}
```

### Telemetry Events

When enabled, ExOanda emits the following telemetry events:

- `[:req, :request, :pipeline, :start]` - Request pipeline starts
- `[:req, :request, :adapter, :start]` - HTTP adapter starts
- `[:req, :request, :adapter, :stop]` - HTTP adapter completes
- `[:req, :request, :adapter, :error]` - HTTP adapter error
- `[:req, :request, :pipeline, :stop]` - Request pipeline completes
- `[:req, :request, :pipeline, :error]` - Request pipeline error

### Configuration Options

```elixir
conn = %ExOanda.Connection{
  token: "1234",
  telemetry: %ExOanda.Telemetry{
    enabled: true,
    use_default_logger: false,  # Set to true for basic console logging
    options: [
      pipeline: true,           # Enable pipeline events (default: true)
      adapter: true,            # Enable adapter events (default: true)
      metadata: %{api_version: "v3", service: "oanda"}
    ]
  }
}
```

### Default Logging

When `use_default_logger` is enabled, you'll see output like:

```text
Req:479128347 - GET https://api-fxtrade.oanda.com/v3/accounts (pipeline)
Req:479128347 - GET https://api-fxtrade.oanda.com/v3/accounts (adapter)
Req:479128347 - 200 in 403ms (adapter)
Req:479128347 - 200 in 413ms (pipeline)
```

## Examples
### Open a trade
```elixir
alias ExOanda.{
  Connection,
  Orders
}

conn = %Connection{token: "1234"}

# Oanda's API will default to a market order with time in force=FOK.
payload = %{
  order: %{
    instrument: "EUR_USD",
    units: 1000 # Use negative units for short
    take_profit_on_fill: %{
      price: 1.0000
    },
    stop_loss_on_fill: %{
      distance: 0.0050 # Price value is also supported
    }
  }
}

# Success status doesn't always mean the order was filled (depending on the options passed in payload)
# If the order was filled immediately, the response will include `order_fill_transaction` (`ExOanda.OrderFillTransaction`)
# with details about the trade that was opened
case Orders.create(conn, "account_id", payload) do
  {:ok, res} -> maybe_persist_trade(res)
  {:error, error} -> handle_error(error)
end
```

### Close a position
```elixir
alias ExOanda.{
  Connection,
  Positions
}

conn = %Connection{token: "1234"}

# Positions can be partially closed by passing an int here or fully closed by passing the string ALL
# Note: when partially closing the position, units will always be positive, even if the position is short
payload = %{
  long_units: "ALL"
}

case Positions.close(conn, "account_id", "EUR_USD", payload) do
  {:ok, res} -> maybe_update_state(res)
  {:error, error} -> handle_error(error)
end
```

### Close a trade
```elixir
alias ExOanda.{
  Connection,
  Trades
}

conn = %Connection{token: "1234"}

# Trades can also be partially closed by passing an int here or fully closed by passing the string ALL
# Note: when partially closing the position, units will always be positive, even if the position is short
# Unlike positions, a direction specific units key is not used here
res = Trades.close(
  %Connection{token: "1234"},
  "account_id",
  "trade_id",
  %{units: "ALL"}
)

case res do
  {:ok, res} -> maybe_update_state(res)
  {:error, error} -> handle_error(error)
end
```

### Stream Prices (in IEx)
```elixir
alias ExOanda.{
  Connection,
  Streaming
}

# Running the following in IEx is a good way to test out streaming prices
# In this example, IO.inspect/1 will receive {:ok, %ExOanda.ClientPrice{...}} or {:error, some_exception}
# For realworld use, you should expect roughly 1 event every 250ms per instrument max
# Use the bang version (price_stream!) if you would rather receive the unwrapped value and/or raise on error
# The HTTP connection with Oanda will periodically die, by default Req will retry the connection
# Your application should also have a process to restart the stream with a backoff if Req's retries fail (depending on how critial realtime prices are to your application)
Streaming.price_stream(
  %Connection{token: "1234"},
  "account_id",
  &IO.inspect/1,
  instruments: ["EUR_USD", "NZD_USD"]
)
```
