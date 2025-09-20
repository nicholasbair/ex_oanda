defmodule ExOanda.Response.TransactionEvent do
  @moduledoc """
  Schema for Oanda streaming transaction response.
  """

  use Ecto.Schema
  import Ecto.Changeset
  import PolymorphicEmbed

  alias ExOanda.{
    OrderFillTransaction,
    TakeProfitOrderTransaction,
    StopLossOrderTransaction,
    TrailingStopLossOrderTransaction,
    MarketOrderRejectTransaction,
    MarketOrderTransaction,
    OrderCancelTransaction,
    TradeClientExtensionsModifyTransaction,
    DailyFinancingTransaction,
    Response.TransactionHeartbeat
  }

  @primary_key false

  embedded_schema do
    polymorphic_embeds_one(:event,
      # Note: this list is incomplete based the Oanda docs
      types: [
        ORDERFILL: OrderFillTransaction,
        TAKE_PROFIT_ORDER: TakeProfitOrderTransaction,
        STOP_LOSS_ORDER: StopLossOrderTransaction,
        TRAILING_STOP_LOSS_ORDER: TrailingStopLossOrderTransaction,
        MARKET_ORDER_REJECT: MarketOrderRejectTransaction,
        MARKET_ORDER: MarketOrderTransaction,
        ORDER_CANCEL: OrderCancelTransaction,
        TRADE_CLIENT_EXTENSIONS_MODIFY: TradeClientExtensionsModifyTransaction,
        DAILY_FINANCING: DailyFinancingTransaction,
        HEARTBEAT: TransactionHeartbeat
      ],
      type_field_name: :type,
      on_type_not_found: :raise,
      on_replace: :update
    )
  end

  @doc false
  def changeset(struct, params) do
    struct
    |> cast(params, [])
    |> cast_polymorphic_embed(:event)
  end
end
