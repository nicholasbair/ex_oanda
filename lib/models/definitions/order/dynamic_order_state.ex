defmodule ExOanda.DynamicOrderState do
  @moduledoc """
  Schema for Oanda dynamic order state.

  [Oanda Docs](https://developer.oanda.com/rest-live-v20/order-df/)
  """

  use TypedEctoSchema
  import Ecto.Changeset

  @primary_key false

  typed_embedded_schema do
    field(:id, :string)
    field(:trailing_stop_value, :float)
    field(:trigger_price, :float)
    field(:is_trigger_value_absolute, :boolean)
    field(:is_trailing_stop_value_absolute, :boolean)
  end

  @doc false
  def changeset(struct, params) do
    struct
    |> cast(params, [:id, :trailing_stop_value, :trigger_price, :is_trigger_value_absolute, :is_trailing_stop_value_absolute])
    |> validate_required([:id, :trailing_stop_value, :trigger_price, :is_trigger_value_absolute, :is_trailing_stop_value_absolute])
  end
end
