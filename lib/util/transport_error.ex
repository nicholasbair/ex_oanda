defmodule ExOanda.TransportError do
  @moduledoc """
  Error raised when transport/connection issues occur.

  This error is raised when Req encounters transport errors, connection issues,
  timeouts, or other network-related problems.
  """

  @type t :: %__MODULE__{
          message: String.t(),
          reason: atom() | String.t(),
          error_type: :transport | :http | :timeout | :connection | :other
        }

  defexception [:message, :reason, :error_type]

  @impl true
  def exception(%Req.TransportError{reason: :timeout}) do
    message = "HTTP timeout: #{format_reason(:timeout)}"
    %__MODULE__{message: message, reason: :timeout, error_type: :timeout}
  end

  def exception(%Req.TransportError{reason: reason}) do
    message = "HTTP transport error: #{format_reason(reason)}"
    %__MODULE__{message: message, reason: reason, error_type: :transport}
  end

  def exception(%Req.HTTPError{protocol: protocol, reason: reason}) do
    message = "HTTP #{protocol} error: #{format_reason(reason)}"
    %__MODULE__{message: message, reason: reason, error_type: :http}
  end

  def exception(%Mint.TransportError{reason: reason}) do
    message = "Connection error: #{format_reason(reason)}"
    %__MODULE__{message: message, reason: reason, error_type: :connection}
  end

  def exception(%Req.TooManyRedirectsError{}) do
    message = "Too many redirects"
    %__MODULE__{message: message, reason: :too_many_redirects, error_type: :http}
  end

  def exception(error) when is_atom(error) do
    message = "HTTP error: #{error}"
    %__MODULE__{message: message, reason: error, error_type: :other}
  end

  def exception(reason) when is_binary(reason) do
    message = "HTTP error: #{reason}"
    %__MODULE__{message: message, reason: reason, error_type: :other}
  end

  def exception(error) do
    message = "HTTP error: #{inspect(error)}"
    %__MODULE__{message: message, reason: error, error_type: :other}
  end

  defp format_reason(reason) when is_atom(reason), do: Atom.to_string(reason)
  defp format_reason(reason) when is_binary(reason), do: reason
  defp format_reason(reason), do: inspect(reason)
end
