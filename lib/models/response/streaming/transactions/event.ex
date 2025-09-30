defmodule ExOanda.Response.TransactionEvent do
  @moduledoc """
  Schema for Oanda streaming transaction response.
  """

  use Ecto.Schema
  import Ecto.Changeset
  import PolymorphicEmbed

  alias ExOanda.{
    ClientConfigureRejectTransaction,
    ClientConfigureTransaction,
    CloseTransaction,
    CreateTransaction,
    DailyFinancingTransaction,
    DelayedTradeClosureTransaction,
    DividendAdjustmentTransaction,
    FixedPriceOrderTransaction,
    GuaranteedStopLossOrderRejectTransaction,
    GuaranteedStopLossOrderTransaction,
    LimitOrderRejectTransaction,
    LimitOrderTransaction,
    MarginCallEnterTransaction,
    MarginCallExitTransaction,
    MarginCallExtendTransaction,
    MarketIfTouchedOrderRejectTransaction,
    MarketIfTouchedOrderTransaction,
    MarketOrderRejectTransaction,
    MarketOrderTransaction,
    OrderCancelRejectTransaction,
    OrderCancelTransaction,
    OrderClientExtensionsModifyRejectTransaction,
    OrderClientExtensionsModifyTransaction,
    OrderFillTransaction,
    ReopenTransaction,
    ResetResettablePLTransaction,
    StopLossOrderRejectTransaction,
    StopLossOrderTransaction,
    TakeProfitOrderRejectTransaction,
    TakeProfitOrderTransaction,
    TradeClientExtensionsModifyRejectTransaction,
    TradeClientExtensionsModifyTransaction,
    TrailingStopLossOrderRejectTransaction,
    TrailingStopLossOrderTransaction,
    TransferFundsRejectTransaction,
    TransferFundsTransaction
  }

  alias ExOanda.Response.TransactionHeartbeat

  @primary_key false

  embedded_schema do
    polymorphic_embeds_one(:event,
      types: [
        ORDER_FILL: OrderFillTransaction,
        ORDER_CANCEL: OrderCancelTransaction,
        ORDER_CANCEL_REJECT: OrderCancelRejectTransaction,
        ORDER_CLIENT_EXTENSIONS_MODIFY: OrderClientExtensionsModifyTransaction,
        ORDER_CLIENT_EXTENSIONS_MODIFY_REJECT: OrderClientExtensionsModifyRejectTransaction,
        CREATE: CreateTransaction,
        CLOSE: CloseTransaction,
        REOPEN: ReopenTransaction,
        CLIENT_CONFIGURE: ClientConfigureTransaction,
        CLIENT_CONFIGURE_REJECT: ClientConfigureRejectTransaction,
        TRANSFER_FUNDS: TransferFundsTransaction,
        TRANSFER_FUNDS_REJECT: TransferFundsRejectTransaction,
        MARKET_ORDER: MarketOrderTransaction,
        MARKET_ORDER_REJECT: MarketOrderRejectTransaction,
        FIXED_PRICE_ORDER: FixedPriceOrderTransaction,
        LIMIT_ORDER: LimitOrderTransaction,
        LIMIT_ORDER_REJECT: LimitOrderRejectTransaction,
        STOP_ORDER: StopLossOrderTransaction,
        STOP_ORDER_REJECT: StopLossOrderRejectTransaction,
        MARKET_IF_TOUCHED_ORDER: MarketIfTouchedOrderTransaction,
        MARKET_IF_TOUCHED_ORDER_REJECT: MarketIfTouchedOrderRejectTransaction,
        TAKE_PROFIT_ORDER: TakeProfitOrderTransaction,
        TAKE_PROFIT_ORDER_REJECT: TakeProfitOrderRejectTransaction,
        GUARANTEED_STOP_LOSS_ORDER: GuaranteedStopLossOrderTransaction,
        GUARANTEED_STOP_LOSS_ORDER_REJECT: GuaranteedStopLossOrderRejectTransaction,
        TRAILING_STOP_LOSS_ORDER: TrailingStopLossOrderTransaction,
        TRAILING_STOP_LOSS_ORDER_REJECT: TrailingStopLossOrderRejectTransaction,
        TRADE_CLIENT_EXTENSIONS_MODIFY: TradeClientExtensionsModifyTransaction,
        TRADE_CLIENT_EXTENSIONS_MODIFY_REJECT: TradeClientExtensionsModifyRejectTransaction,
        MARGIN_CALL_ENTER: MarginCallEnterTransaction,
        MARGIN_CALL_EXTEND: MarginCallExtendTransaction,
        MARGIN_CALL_EXIT: MarginCallExitTransaction,
        DELAYED_TRADE_CLOSURE: DelayedTradeClosureTransaction,
        DAILY_FINANCING: DailyFinancingTransaction,
        DIVIDEND_ADJUSTMENT: DividendAdjustmentTransaction,
        RESET_RESETTABLE_PL: ResetResettablePLTransaction,
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
