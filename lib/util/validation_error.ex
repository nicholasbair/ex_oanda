defmodule ExOanda.ValidationError do
  @moduledoc """
  Error raised when parameter or request body validation fails.

  This error is raised when:
  - NimbleOptions validation fails for function parameters (error in `error` field, `validation_type: :parameter_validation`)
  - Ecto changeset validation fails for request body validation (changeset in `error` field, `validation_type: :request_body_validation`)

  It provides a more user-friendly error message and structured error data.
  The `validation_type` field indicates which type of validation failed.
  """

  @type validation_type :: :parameter_validation | :request_body_validation

  @type t :: %__MODULE__{
          message: String.t(),
          error: NimbleOptions.ValidationError.t() | Ecto.Changeset.t(),
          validation_type: validation_type()
        }

  defexception [:message, :error, :validation_type]

  @impl true
  def exception(%NimbleOptions.ValidationError{} = validation_error) do
    message = "Parameter validation failed: #{validation_error.message}"
    %__MODULE__{message: message, error: validation_error, validation_type: :parameter_validation}
  end

  def exception(%Ecto.Changeset{} = changeset) do
    message = "Request body validation failed: #{format_changeset_errors(changeset)}"
    %__MODULE__{message: message, error: changeset, validation_type: :request_body_validation}
  end

  defp format_changeset_errors(changeset) do
    changeset
    |> Ecto.Changeset.traverse_errors(fn
      {msg, opts} ->
        Enum.reduce(opts, msg, fn {key, value}, acc ->
          String.replace(acc, "%{#{key}}", to_string(value))
        end)
      errors when is_list(errors) ->
        errors
    end)
    |> Enum.map_join(", ", &format_field_error/1)
  end

  defp format_field_error({field, error}) do
    case error do
      {message, _opts} when is_binary(message) ->
        "#{field}: #{message}"
      errors when is_list(errors) ->
        formatted_errors = Enum.map(errors, &format_embedded_error/1)
        "#{field}: #{Enum.join(formatted_errors, ", ")}"
      error ->
        "#{field}: #{inspect(error)}"
    end
  end

  defp format_embedded_error({key, messages}) when is_atom(key) and is_list(messages) do
    "#{key}: #{Enum.join(messages, ", ")}"
  end

  defp format_embedded_error(error), do: inspect(error)
end
