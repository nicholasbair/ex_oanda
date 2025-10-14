defmodule ExOanda.Telemetry do
  @moduledoc """
  Telemetry configuration and utilities for ExOanda HTTP requests.

  This module provides telemetry instrumentation for OANDA API requests using
  [ReqTelemetry](https://hexdocs.pm/req_telemetry/ReqTelemetry.html).

  ## Telemetry Events

  When enabled, this module will emit the following telemetry events:

  * `[:req, :request, :pipeline, :start]` - Request pipeline starts
  * `[:req, :request, :adapter, :start]` - HTTP adapter starts
  * `[:req, :request, :adapter, :stop]` - HTTP adapter completes
  * `[:req, :request, :adapter, :error]` - HTTP adapter error
  * `[:req, :request, :pipeline, :stop]` - Request pipeline completes
  * `[:req, :request, :pipeline, :error]` - Request pipeline error

  ## Configuration

  Telemetry can be configured through the `ExOanda.Connection` struct:

      # Enable telemetry with default settings
      conn = %ExOanda.Connection{
        telemetry: %ExOanda.Telemetry{
          enabled: true,
          use_default_logger: false,
          options: []
        }
      }

      # Enable telemetry with custom options
      conn = %ExOanda.Connection{
        telemetry: %ExOanda.Telemetry{
          enabled: true,
          use_default_logger: true,
          options: [
            pipeline: true,
            adapter: true,
            metadata: %{api_version: "v3"}
          ]
        }
      }

  ## Options

  * `:pipeline` (default `true`) - Emit pipeline telemetry events
  * `:adapter` (default `true`) - Emit adapter telemetry events
  * `:metadata` (default `nil`) - User-supplied metadata available in telemetry handlers

  ## Default Logging

  When `use_default_logger` is enabled, ReqTelemetry will automatically attach
  a basic logger that outputs request information and timing to the console.
  This is useful for development and debugging.

  Example log output:
  ```
  Req:479128347 - GET https://api-fxtrade.oanda.com/v3/accounts (pipeline)
  Req:479128347 - GET https://api-fxtrade.oanda.com/v3/accounts (adapter)
  Req:479128347 - 200 in 403ms (adapter)
  Req:479128347 - 200 in 413ms (pipeline)
  ```

  ## Usage

  This module is typically used internally by ExOanda when making API requests.
  The `maybe_attach_telemetry/2` function is called automatically based on
  your connection configuration.

  ## Performance Considerations

  Telemetry instrumentation adds minimal overhead to requests, but you may
  want to disable it in production environments where detailed request
  monitoring isn't needed.
  """

  alias ExOanda.Connection, as: Conn

  @type t :: %__MODULE__{
    enabled: boolean(),
    use_default_logger: boolean(),
    options: options()
  }

  @type options() :: boolean() | [option()]
  @type option() :: {:adapter, boolean()} | {:pipeline, boolean()} | {:metadata, map()}

  defstruct [
    enabled: false,
    use_default_logger: false,
    options: []
  ]

  @spec maybe_attach_telemetry(Req.Request.t(), Conn.t()) :: Req.Request.t()
  def maybe_attach_telemetry(req, %{telemetry: %{enabled: true}} = conn) do
    if conn.telemetry.use_default_logger do
      ReqTelemetry.attach_default_logger()
    end

    ReqTelemetry.attach(req, conn.telemetry.options)
  end
  def maybe_attach_telemetry(req, %{telemetry: %{enabled: false}} = _conn), do: req
  def maybe_attach_telemetry(req, _), do: req
end
