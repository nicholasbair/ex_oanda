defmodule ExOanda.TradeOpened do
  @moduledoc """
  Schema for Oanda trade opened.

  [Oanda Docs](https://developer.oanda.com/rest-live-v20/trade-df/)
  """

  use TypedEctoSchema
  import Ecto.Changeset
  alias ExOanda.ClientExtensions

  @primary_key false

  typed_embedded_schema do
    field(:trade_id, :string)
    field(:units, :integer)
    field(:price, :float)
    field(:half_spread_cost, :float)
    field(:initial_margin_required, :float)
    field(:guaranteed_execution_fee, :float)
    field(:quote_guaranteed_execution_fee, :float)

    embeds_one :client_extensions, ClientExtensions
  end

  @doc false
  def changeset(struct, params) do
    struct
    |> cast(params, [
      :trade_id, :units, :price, :half_spread_cost, :initial_margin_required,
      :guaranteed_execution_fee, :quote_guaranteed_execution_fee
    ])
    |> cast_embed(:client_extensions)
    |> validate_required([
      :trade_id, :units, :price, :half_spread_cost, :initial_margin_required,
      :guaranteed_execution_fee, :quote_guaranteed_execution_fee
    ])
  end
end
