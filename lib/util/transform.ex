defmodule ExOanda.Transform do
  @moduledoc false

  import Ecto.Changeset
  require Logger
  alias ExOanda.{
    CodeGenerator,
    HttpStatus,
    Response
  }

  @spec transform(map(), atom()) :: Response.t()
  def transform(response, model) do
    %Response{}
    |> Response.changeset(preprocess_body(model, response))
    |> apply_changes()
  end

  defp preprocess_body(model, response) do
    data =
      response
      |> Map.get(:body)
      |> then(&preprocess_data(model, &1))

    status =
      response
      |> Map.get(:status)
      |> HttpStatus.status_to_atom()

    request_id =
      response
      |> Map.get(:headers, %{})
      |> Map.get("requestid", [])
      |> List.first()

    %{"data" => data, "status" => status, "request_id" => request_id}
  end

  @spec preprocess_data(nil | atom(), map()) :: [Ecto.Schema.t()] | [map()] | Ecto.Schema.t() | map()
  def preprocess_data(nil, data), do: data

  def preprocess_data(model, data) when is_map(data) do
    model.__struct__()
    |> model.changeset(Recase.Enumerable.convert_keys(data, &Recase.to_snake/1))
    |> log_validations(model)
    |> apply_changes()
  end

  def preprocess_data(model, data) when is_list(data) do
    Enum.map(data, &preprocess_data(model, &1))
  end

  def preprocess_data(_model, data), do: data

  defp log_validations(%{valid?: true} = changeset, _model), do: changeset

  defp log_validations(changeset, model) do
    traverse_errors(changeset, fn _changeset, field, {msg, opts} ->
      Logger.warning("Validation error while transforming #{CodeGenerator.format_module_name(model)}: #{field} #{msg} #{inspect(opts)}")
    end)

    changeset
  end
end
