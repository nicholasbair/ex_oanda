defmodule ExOanda.Response.UpdateTrade do
  @moduledoc """
  Schema for Oanda update trade response.
  """

  use TypedEctoSchema
  import Ecto.Changeset
  alias ExOanda.{
    OrderCancelTransaction,
    TakeProfitOrderTransaction,
    OrderFillTransaction,
    OrderCancelRejectTransaction,
    TakeProfitOrderRejectTransaction,
    StopLossOrderTransaction,
    StopLossOrderRejectTransaction,
    TrailingStopLossOrderTransaction,
    TrailingStopLossOrderRejectTransaction,
    GuaranteedStopLossOrderTransaction,
    GuaranteedStopLossOrderRejectTransaction
  }

  @primary_key false

  typed_embedded_schema do
    embeds_one :take_profit_order_cancel_transaction, OrderCancelTransaction
    embeds_one :take_profit_order_transaction, TakeProfitOrderTransaction
    embeds_one :take_profit_order_fill_transaction, OrderFillTransaction
    embeds_one :take_profit_order_created_cancel_transaction, OrderCancelTransaction
    embeds_one :stop_loss_order_cancel_transaction, OrderCancelTransaction
    embeds_one :stop_loss_order_transaction, StopLossOrderTransaction
    embeds_one :stop_loss_order_fill_transaction, OrderFillTransaction
    embeds_one :stop_loss_order_created_cancel_transaction, OrderCancelTransaction
    embeds_one :trailing_stop_loss_order_cancel_transaction, OrderCancelTransaction
    embeds_one :trailing_stop_loss_order_transaction, TrailingStopLossOrderTransaction
    embeds_one :guaranteed_stop_loss_order_cancel_transaction, OrderCancelTransaction
    embeds_one :guaranteed_stop_loss_order_transaction, GuaranteedStopLossOrderTransaction

    embeds_one :take_profit_order_cancel_reject_transaction, OrderCancelRejectTransaction
    embeds_one :take_profit_order_reject_transaction, TakeProfitOrderRejectTransaction
    embeds_one :stop_loss_order_cancel_reject_transaction, OrderCancelRejectTransaction
    embeds_one :stop_loss_order_reject_transaction, StopLossOrderRejectTransaction
    embeds_one :trailing_stop_loss_order_cancel_reject_transaction, OrderCancelRejectTransaction
    embeds_one :trailing_stop_loss_order_reject_transaction, TrailingStopLossOrderRejectTransaction
    embeds_one :guaranteed_stop_loss_order_cancel_reject_transaction, OrderCancelRejectTransaction
    embeds_one :guaranteed_stop_loss_order_reject_transaction, GuaranteedStopLossOrderRejectTransaction

    field(:related_transaction_ids, {:array, :string})
    field(:last_transaction_id, :string)
  end

  @doc false
  def changeset(struct, params) do
    struct
    |> cast(params, [:related_transaction_ids, :last_transaction_id])
    |> cast_embed(:take_profit_order_cancel_transaction)
    |> cast_embed(:take_profit_order_transaction)
    |> cast_embed(:take_profit_order_fill_transaction)
    |> cast_embed(:take_profit_order_created_cancel_transaction)
    |> cast_embed(:stop_loss_order_cancel_transaction)
    |> cast_embed(:stop_loss_order_transaction)
    |> cast_embed(:stop_loss_order_fill_transaction)
    |> cast_embed(:stop_loss_order_created_cancel_transaction)
    |> cast_embed(:trailing_stop_loss_order_cancel_transaction)
    |> cast_embed(:trailing_stop_loss_order_transaction)
    |> cast_embed(:guaranteed_stop_loss_order_cancel_transaction)
    |> cast_embed(:guaranteed_stop_loss_order_transaction)
    |> cast_embed(:take_profit_order_cancel_reject_transaction)
    |> cast_embed(:take_profit_order_reject_transaction)
    |> cast_embed(:stop_loss_order_cancel_reject_transaction)
    |> cast_embed(:stop_loss_order_reject_transaction)
    |> cast_embed(:trailing_stop_loss_order_cancel_reject_transaction)
    |> cast_embed(:trailing_stop_loss_order_reject_transaction)
    |> cast_embed(:guaranteed_stop_loss_order_cancel_reject_transaction)
    |> cast_embed(:guaranteed_stop_loss_order_reject_transaction)
  end
end
