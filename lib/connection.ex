defmodule ExOanda.Connection do
  @moduledoc """
  Connection module for Oanda API
  """

  @type t :: %__MODULE__{
    token: String.t(),
    api_server: String.t(),
    stream_server: String.t(),
    options: list(),
    telemetry: boolean()
  }

  @enforce_keys [:token]
  defstruct [
    :token,
    api_server: "https://api-fxpractice.oanda.com/v3",
    stream_server: "https://stream-fxpractice.oanda.com/v3",
    options: [],
    telemetry: false
  ]
end
