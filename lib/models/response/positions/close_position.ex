defmodule ExOanda.Response.ClosePosition do
  @moduledoc """
  Schema for Oanda close position response.
  """

  use TypedEctoSchema
  import Ecto.Changeset
  alias ExOanda.{
    MarketOrderTransaction,
    OrderFillTransaction,
    OrderCancelTransaction,
    MarketOrderRejectTransaction
  }

  @primary_key false

  typed_embedded_schema do
    field(:related_transaction_ids, {:array, :string})
    field(:last_transaction_id, :string)
    field(:error_code, :string)
    field(:error_message, :string)

    embeds_one :long_order_create_transaction, MarketOrderTransaction
    embeds_one :long_order_fill_transaction, OrderFillTransaction
    embeds_one :long_order_cancel_transaction, OrderCancelTransaction
    embeds_one :short_order_create_transaction, MarketOrderTransaction
    embeds_one :short_order_fill_transaction, OrderFillTransaction
    embeds_one :short_order_cancel_transaction, OrderCancelTransaction
    embeds_one :long_order_reject_transaction, MarketOrderRejectTransaction
    embeds_one :short_order_reject_transaction, MarketOrderRejectTransaction
  end

  @doc false
  def changeset(struct, params) do
    struct
    |> cast(params, [:related_transaction_ids, :last_transaction_id, :error_code, :error_message])
    |> cast_embed(:long_order_create_transaction)
    |> cast_embed(:long_order_fill_transaction)
    |> cast_embed(:long_order_cancel_transaction)
    |> cast_embed(:short_order_create_transaction)
    |> cast_embed(:short_order_fill_transaction)
    |> cast_embed(:short_order_cancel_transaction)
    |> cast_embed(:long_order_reject_transaction)
    |> cast_embed(:short_order_reject_transaction)
  end
end
