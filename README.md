Unofficial Elixir SDK for the Oanda API.

Note - this SDK is in active development, not recommended for production use.

## Notes

*Forex Trading Risk Dislaimer*

Trading foreign exchange (forex) on margin carries a high level of risk and may not be suitable for all investors. The leveraged nature of forex trading can amplify both profits and losses, potentially resulting in the loss of all invested capital. Before engaging in forex trading, please carefully consider your investment objectives, experience level, and risk tolerance.

This SDK is provided "as-is," without any warranty of any kind, either expressed or implied, including but not limited to the implied warranties of merchantability, fitness for a particular purpose, or non-infringement. The use of this SDK is at your own risk, and we make no guarantees regarding its accuracy, reliability, or suitability for any specific trading strategy or purpose. Users are responsible for their own trading decisions and should seek independent financial advice if necessary.

## TODO / Known Issues
1. Not all schemas have been validated against Oanda's live API
2. Not yet available on hex

## Installation
```elixir
def deps do
  [
    {:ex_oanda, git: "https://github.com/nicholasbair/ex_oanda.git", tag: "v0.0.20"}
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
      enabled: true,
      use_default_logger: true,
      options: []
    }
  }
```

Options from `ExOanda.Connection` are passed directly to [Req](https://hexdocs.pm/req/Req.html) and can be used to override the default behavior of the HTTP client.  You can find a complete list of options [here](https://hexdocs.pm/req/Req.html#new/1).  The most relevent Req defaults are listed below:
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
{:ok, accounts} =
  %ExOanda.Connection{token: "1234"}
  |> ExOanda.Accounts.list_changes("account_id", since_transaction_id: "5678")

# Incorrect filter
{:error, %ExOanda.ValidationError{}} =
  %ExOanda.Connection{token: "1234"}
  |> ExOanda.Accounts.list_changes("account_id", since_transaction_id: 1234)
```

4. [Ecto](https://hex.pm/packages/ecto) is used to validate request payloads and transform response payloads from Oanda into structs.

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

```
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

# Market order, no TP/SL/TS, etc.
payload = %{
  order: %{
    instrument: "EUR_USD",
    units: 1000
  }
}

case Orders.create(conn, "account_id", payload) do
  {:ok, res} -> maybe_persist_trade(res) # Success status doesn't mean the order was filled, only that it was created/accepted
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
payload = %{
  long_units: "ALL"
}

case Positions.close(conn, "account_id", "EUR_USD", payload) do
  {:ok, res} -> maybe_update_state(res) # Success status doesn't mean the close order was filled, only that it was created/accepted
  {:error, error} -> handle_error(error)
end
```

### Stream Prices
```elixir
alias ExOanda.{
  Connection,
  Streaming
}

# The HTTP connection with Oanda will periodically die, by default Req will retry the connection
# Your application should also have a process to restart the stream with a backoff if Req's retries fail
# IO.inspect/1 will receive {:ok, %ExOanda.ClientPrice{...}} or {:error, some_exception}
# Use the bang version (price_stream!) if you would rather raise
Streaming.price_stream(
  %Connection{token: "1234"},
  "account_id",
  &IO.inspect/1,
  instruments: ["EUR_USD", "NZD_USD"]
)
```
