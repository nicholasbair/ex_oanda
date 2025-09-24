defmodule ExOanda.ValidationError do
  @moduledoc """
  Error raised when parameter validation fails.

  This error is raised when NimbleOptions validation fails for function parameters.
  It provides a more user-friendly error message and structured error data.
  """

  @type t :: %__MODULE__{
          message: String.t(),
          errors: [NimbleOptions.ValidationError.t()]
        }

  defexception [:message, :errors]

  @impl true
  def exception(nimble_errors) when is_list(nimble_errors) do
    message = "Parameter validation failed: #{format_errors(nimble_errors)}"
    %__MODULE__{message: message, errors: nimble_errors}
  end

  def exception(%NimbleOptions.ValidationError{} = validation_error) do
    message = "Parameter validation failed: #{validation_error.message}"
    %__MODULE__{message: message, errors: [validation_error]}
  end

  defp format_errors(errors) do
    Enum.map_join(errors, ", ", fn %{message: message, key: key} -> "#{key}: #{message}" end)
  end
end
