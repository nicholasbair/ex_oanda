defmodule ExOandaError do
  @moduledoc """
  Standard error wrapper
  """

  @type t :: %__MODULE__{message: String.t()}

  defexception [:message]

  @impl true
  def exception(value) do
    msg = "Error: #{inspect(value)}"
    %ExOandaError{message: msg}
  end
end
