defmodule ExOanda.APIError do
  @moduledoc """
  Error raised when Oanda API returns an error response.

  This error is raised when the Oanda API returns a non-2xx status code
  that doesn't fall into other specific error categories.
  """

  @type t :: %__MODULE__{message: String.t()}

  defexception [:message]

  @impl true
  def exception(value) do
    msg = "API Error: #{inspect(value)}"
    %__MODULE__{message: msg}
  end
end
