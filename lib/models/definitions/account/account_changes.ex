defmodule ExOanda.AccountChanges do
  @moduledoc """
  Schema for Oanda account changes.

  [Oanda Docs](https://developer.oanda.com/rest-live-v20/account-df/)
  """

  use TypedEctoSchema
  import Ecto.Changeset
  import PolymorphicEmbed

  alias ExOanda.{
    ClientConfigureRejectTransaction,
    ClientConfigureTransaction,
    DailyFinancingTransaction,
    DelayedTradeClosureTransaction,
    DividendAdjustmentTransaction,
    FixedPriceOrderTransaction,
    GuaranteedStopLossOrderRejectTransaction,
    GuaranteedStopLossOrderTransaction,
    LimitOrderRejectTransaction,
    LimitOrderTransaction,
    MarginCallEnterTransaction,
    MarginCallExtendTransaction,
    MarginCallExitTransaction,
    MarketIfTouchedOrderRejectTransaction,
    MarketIfTouchedOrderTransaction,
    MarketOrderRejectTransaction,
    MarketOrderTransaction,
    Order,
    OrderCancelRejectTransaction,
    OrderCancelTransaction,
    OrderClientExtensionsModifyRejectTransaction,
    OrderClientExtensionsModifyTransaction,
    OrderFillTransaction,
    OrderRejectTransaction,
    Position,
    ResetResettablePLTransaction,
    StopLossOrderRejectTransaction,
    StopLossOrderTransaction,
    TakeProfitOrderRejectTransaction,
    TakeProfitOrderTransaction,
    TradeClientExtensionsModifyRejectTransaction,
    TradeClientExtensionsModifyTransaction,
    TradeSummary,
    TrailingStopLossOrderRejectTransaction,
    TrailingStopLossOrderTransaction,
    TransferFundsRejectTransaction,
    TransferFundsTransaction
  }

  @primary_key false

  typed_embedded_schema do
    embeds_many(:orders_created, Order)
    embeds_many(:orders_cancelled, Order)
    embeds_many(:orders_filled, Order)
    embeds_many(:orders_triggered, Order)
    embeds_many(:trades_opened, TradeSummary)
    embeds_many(:trades_reduced, TradeSummary)
    embeds_many(:trades_closed, TradeSummary)
    embeds_many(:positions, Position)

    polymorphic_embeds_many(:transactions,
      types: [
        CLIENT_CONFIGURE: ClientConfigureTransaction,
        CLIENT_CONFIGURE_REJECT: ClientConfigureRejectTransaction,
        DAILY_FINANCING: DailyFinancingTransaction,
        DELAYED_TRADE_CLOSURE: DelayedTradeClosureTransaction,
        DIVIDEND_ADJUSTMENT: DividendAdjustmentTransaction,
        FIXED_PRICE_ORDER: FixedPriceOrderTransaction,
        GUARANTEED_STOP_LOSS_ORDER: GuaranteedStopLossOrderTransaction,
        GUARANTEED_STOP_LOSS_ORDER_REJECT: GuaranteedStopLossOrderRejectTransaction,
        LIMIT_ORDER: LimitOrderTransaction,
        LIMIT_ORDER_REJECT: LimitOrderRejectTransaction,
        MARGIN_CALL_ENTER: MarginCallEnterTransaction,
        MARGIN_CALL_EXTEND: MarginCallExtendTransaction,
        MARGIN_CALL_EXIT: MarginCallExitTransaction,
        MARKET_IF_TOUCHED_ORDER: MarketIfTouchedOrderTransaction,
        MARKET_IF_TOUCHED_ORDER_REJECT: MarketIfTouchedOrderRejectTransaction,
        MARKET_ORDER: MarketOrderTransaction,
        MARKET_ORDER_REJECT: MarketOrderRejectTransaction,
        ORDER_CANCEL: OrderCancelTransaction,
        ORDER_CANCEL_REJECT: OrderCancelRejectTransaction,
        ORDER_CLIENT_EXTENSIONS_MODIFY: OrderClientExtensionsModifyTransaction,
        ORDER_CLIENT_EXTENSIONS_MODIFY_REJECT: OrderClientExtensionsModifyRejectTransaction,
        ORDER_FILL: OrderFillTransaction,
        ORDER_REJECT: OrderRejectTransaction,
        RESET_RESETTABLE_PL: ResetResettablePLTransaction,
        STOP_LOSS_ORDER: StopLossOrderTransaction,
        STOP_LOSS_ORDER_REJECT: StopLossOrderRejectTransaction,
        TAKE_PROFIT_ORDER: TakeProfitOrderTransaction,
        TAKE_PROFIT_ORDER_REJECT: TakeProfitOrderRejectTransaction,
        TRADE_CLIENT_EXTENSIONS_MODIFY: TradeClientExtensionsModifyTransaction,
        TRADE_CLIENT_EXTENSIONS_MODIFY_REJECT: TradeClientExtensionsModifyRejectTransaction,
        TRAILING_STOP_LOSS_ORDER: TrailingStopLossOrderTransaction,
        TRAILING_STOP_LOSS_ORDER_REJECT: TrailingStopLossOrderRejectTransaction,
        TRANSFER_FUNDS: TransferFundsTransaction,
        TRANSFER_FUNDS_REJECT: TransferFundsRejectTransaction
      ],
      on_type_not_found: :raise,
      on_replace: :delete,
      type_field_name: :type
    )
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
