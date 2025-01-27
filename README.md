# ExOanda
Unofficial Elixir SDK for the Oanda API.

Note - this is highly experimental and in active development.

## Notes

*Forex Trading Risk Dislaimer*

Trading foreign exchange (forex) on margin carries a high level of risk and may not be suitable for all investors. The leveraged nature of forex trading can amplify both profits and losses, potentially resulting in the loss of all invested capital. Before engaging in forex trading, please carefully consider your investment objectives, experience level, and risk tolerance.

This SDK is provided "as-is," without any warranty of any kind, either expressed or implied, including but not limited to the implied warranties of merchantability, fitness for a particular purpose, or non-infringement. The use of this SDK is at your own risk, and we make no guarantees regarding its accuracy, reliability, or suitability for any specific trading strategy or purpose. Users are responsible for their own trading decisions and should seek independent financial advice if necessary.

## TODO / Known Issues
1. Limited test coverage, validation of schemas
2. Not yet available on hex

## Installation
```elixir
def deps do
  [
    {:ex_oanda, git: "https://github.com/nicholasbair/ex_oanda.git", tag: "v0.0.10"}
  ]
end
```

## Usage
1. Connection is a struct that stores your Oanda API credentials.
```elixir
conn = 
  %ExOanda.Connection{
    token: "1234", # Configured in the Oanda API
    api_server: "https://api-fxpractice.oanda.com/v3",
    stream_server: "https://stream-fxpractice.oanda.com/v3",
    options: [], # Passed to Req (HTTP client)
    telemetry: true # Enables telemetry and the default telemetry logger (defaults to `false`)
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
{:ok, threads} = 
  %ExOanda.Connection{token: "1234"}
  |> ExOanda.Accounts.list_changes("account_id", since_transaction_id: "5678")
```

4. [Ecto](https://hex.pm/packages/ecto) is also used when transforming the API response from Oanda into structs.  Any validation errors are logged, but errors are not returned/raised in order to make to SDK resilient to changes to the API contract.