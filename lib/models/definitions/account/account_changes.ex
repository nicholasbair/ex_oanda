defmodule ExOanda.AccountChanges do
  @moduledoc """
  Schema for Oanda account changes.
  """

  use TypedEctoSchema
  import Ecto.Changeset
  import PolymorphicEmbed

  alias ExOanda.{
    Order,
    Position,
    TradeSummary,
    DailyFinancing,
    MarketOrderTransaction,
    MarketOrderRejectTransaction,
    OrderFillTransaction,
    TradeClientExtensionsModifyTransaction
  }

  @primary_key false

  typed_embedded_schema do
    embeds_many :orders_created, Order
    embeds_many :orders_cancelled, Order
    embeds_many :orders_filled, Order
    embeds_many :orders_triggered, Order
    embeds_many :trades_opened, TradeSummary
    embeds_many :trades_reduced, TradeSummary
    embeds_many :trades_closed, TradeSummary
    embeds_many :positions, Position
    polymorphic_embeds_many :transactions,
      types: [
        DAILY_FINANCING: DailyFinancing,
        MARKET_ORDER: MarketOrderTransaction,
        MARKET_ORDER_REJECT: MarketOrderRejectTransaction,
        ORDER_FILL: OrderFillTransaction,
        TRADE_CLIENT_EXTENSIONS_MODIFY: TradeClientExtensionsModifyTransaction,
      ],
      on_type_not_found: :changeset_error,
      on_replace: :delete,
      type_field_name: :type
  end

  @doc false
  def changeset(struct, params) do
    struct
    |> cast(params, [])
    |> cast_embed(:orders_created)
    |> cast_embed(:orders_cancelled)
    |> cast_embed(:orders_filled)
    |> cast_embed(:orders_triggered)
    |> cast_embed(:trades_opened)
    |> cast_embed(:trades_reduced)
    |> cast_embed(:trades_closed)
    |> cast_embed(:positions)
    |> cast_polymorphic_embed(:transactions)
  end
end
