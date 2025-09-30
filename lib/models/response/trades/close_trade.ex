defmodule ExOanda.Response.CloseTrade do
  @moduledoc """
  Schema for Oanda close trade response.

  [Oanda Docs](https://developer.oanda.com/rest-live-v20/trade-ep/)
  """

  use TypedEctoSchema
  import Ecto.Changeset
  alias ExOanda.{
    MarketOrderRejectTransaction,
    MarketOrderTransaction,
    OrderCancelTransaction,
    OrderFillTransaction
  }

  @primary_key false

  typed_embedded_schema do
    field(:related_transaction_ids, {:array, :string})
    field(:last_transaction_id, :string)

    embeds_one :order_create_transaction, MarketOrderTransaction
    embeds_one :order_fill_transaction, OrderFillTransaction
    embeds_one :order_cancel_transaction, OrderCancelTransaction
    embeds_one :order_reject_transaction, MarketOrderRejectTransaction
  end

  @doc false
  def changeset(struct, params) do
    struct
    |> cast(params, [:related_transaction_ids, :last_transaction_id])
    |> cast_embed(:order_create_transaction)
    |> cast_embed(:order_fill_transaction)
    |> cast_embed(:order_cancel_transaction)
    |> cast_embed(:order_reject_transaction)
  end
end
