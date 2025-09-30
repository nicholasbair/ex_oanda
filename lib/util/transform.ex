defmodule ExOanda.Transform do
  @moduledoc false

  import Ecto.Changeset
  require Logger
  alias ExOanda.{
    ClientPrice,
    CodeGenerator,
    HttpStatus,
    Response,
    Response.PricingHeartbeat,
    Response.TransactionEvent
  }

  @spec transform(map(), atom()) :: Response.t()
  def transform(response, model) do
    %Response{}
    |> Response.changeset(preprocess_body(model, response))
    |> apply_changes()
  end

  def transform_stream(val, stream_type) do
    val
    |> Jason.decode!()
    |> find_stream_schema(stream_type)
    |> then(fn {schema, data} -> preprocess_data(schema, data) end)
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

    error_code =
      response
      |> Map.get(:body, %{})
      |> Map.get("errorCode", nil)

    error_message =
      response
      |> Map.get(:body, %{})
      |> Map.get("errorMessage", nil)

    %{
      "data" => data,
      "status" => status,
      "request_id" => request_id,
      "error_code" => error_code,
      "error_message" => error_message
    }
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
      module_name = CodeGenerator.format_module_name(model)
      Logger.warning(
        "Validation error while transforming #{module_name}: #{field} #{msg} #{inspect(opts)}"
      )
    end)

    changeset
  end

  # Transactions are varied, so polymorphic embed is used to handle different types of transactions.
  defp find_stream_schema(val, :transactions), do: {TransactionEvent, %{"event" => val}}

  defp find_stream_schema(%{"type" => "HEARTBEAT"} = val, :pricing), do: {PricingHeartbeat, val}
  defp find_stream_schema(val, :pricing), do: {ClientPrice, val}
end
