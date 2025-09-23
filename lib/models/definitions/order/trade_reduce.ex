defmodule ExOanda.TradeReduce do
  @moduledoc """
  Schema for Oanda trade reduce response.

  [Oanda Docs](https://developer.oanda.com/rest-live-v20/order-df/)
  """

  use TypedEctoSchema
  import Ecto.Changeset

  @primary_key false

  typed_embedded_schema do
    field(:trade_id, :string)
    field(:units, :integer)
    field(:price, :float)
    field(:realized_pl, :float)
    field(:financing, :float)
    field(:base_financing, :float)
    field(:quote_financing, :float)
    field(:financing_rate, :float)
    field(:guaranteed_execution_fee, :float)
    field(:quote_guaranteed_execution_fee, :float)
    field(:half_spread_cost, :float)
  end

  @doc false
  def changeset(struct, params) do
    struct
    |> cast(params, [
      :trade_id, :units, :price, :realized_pl, :financing, :base_financing,
      :quote_financing, :financing_rate, :guaranteed_execution_fee,
      :quote_guaranteed_execution_fee, :half_spread_cost
    ])
    |> validate_required([
      :trade_id, :units, :price, :realized_pl, :financing,
      :base_financing, :guaranteed_execution_fee,
      :quote_guaranteed_execution_fee, :half_spread_cost
    ])
  end
end
