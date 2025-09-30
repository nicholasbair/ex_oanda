defmodule ExOanda.DecodeError do
  @moduledoc """
  Error raised when JSON decoding fails.

  This error is raised when Jason.decode!/1 encounters invalid JSON
  during streaming operations or other JSON parsing scenarios.
  """

  @type t :: %__MODULE__{
          message: String.t(),
          reason: String.t() | atom()
        }

  defexception [:message, :reason]

  @impl true
  def exception(%Jason.DecodeError{data: data, position: position}) when not is_nil(position) do
    message = "JSON decode error at position #{position}: #{inspect(data)}"
    %__MODULE__{message: message, reason: :invalid_json}
  end

  def exception(%Jason.DecodeError{data: data}) do
    message = "JSON decode error: #{inspect(data)}"
    %__MODULE__{message: message, reason: :invalid_json}
  end

  def exception(reason) when is_binary(reason) do
    message = "JSON decode error: #{reason}"
    %__MODULE__{message: message, reason: reason}
  end

  def exception(reason) when is_atom(reason) do
    message = "JSON decode error: #{reason}"
    %__MODULE__{message: message, reason: reason}
  end

  def exception(error) do
    message = "JSON decode error: #{inspect(error)}"
    %__MODULE__{message: message, reason: error}
  end
end
