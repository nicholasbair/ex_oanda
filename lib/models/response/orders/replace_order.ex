defmodule ExOanda.Response.ReplaceOrder do
  @moduledoc """
  Schema for Oanda replace order response.
  """

  use TypedEctoSchema
  import Ecto.Changeset
  alias ExOanda.{
    OrderFillTransaction,
    OrderCancelTransaction,
    Transaction
  }

  @primary_key false

  typed_embedded_schema do
    embeds_one :order_cancel_transaction, OrderCancelTransaction
    embeds_one :order_create_transaction, Transaction
    embeds_one :order_fill_transaction, OrderFillTransaction
    embeds_one :order_reissue_transaction, Transaction
    embeds_one :order_reissue_reject_transaction, Transaction
    embeds_one :replacing_order_cancel_transaction, OrderCancelTransaction
    embeds_one :order_reject_transaction, Transaction
    embeds_one :order_cancel_reject_transaction, Transaction

    field(:error_code, :string)
    field(:error_message, :string)
    field(:related_transaction_ids, {:array, :string})
    field(:last_transaction_id, :string)
  end

  @doc false
  def changeset(struct, params) do
    struct
    |> cast(params, [:related_transaction_ids, :last_transaction_id])
    |> cast_embed(:order_cancel_transaction)
    |> cast_embed(:order_create_transaction)
    |> cast_embed(:order_fill_transaction)
    |> cast_embed(:order_reissue_transaction)
    |> cast_embed(:order_reissue_reject_transaction)
    |> cast_embed(:replacing_order_cancel_transaction)
    |> cast_embed(:order_reject_transaction)
    |> cast_embed(:order_cancel_reject_transaction)
  end
end
