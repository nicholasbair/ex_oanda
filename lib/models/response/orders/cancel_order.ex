defmodule ExOanda.Response.CancelOrder do
  @moduledoc """
  Schema for Oanda cancel order response.
  """

  use TypedEctoSchema
  import Ecto.Changeset
  alias ExOanda.{
    OrderCancelTransaction,
    OrderCancelRejectTransaction
  }

  @primary_key false

  typed_embedded_schema do
    embeds_one :order_cancel_transaction, OrderCancelTransaction
    embeds_one :order_cancel_reject_transaction, OrderCancelRejectTransaction
    field(:related_transaction_ids, {:array, :string})
    field(:last_transaction_id, :string)
    field(:error_code, :string)
    field(:error_message, :string)
  end

  @doc false
  def changeset(struct, params) do
    struct
    |> cast(params, [:related_transaction_ids, :last_transaction_id, :error_code, :error_message])
    |> cast_embed(:order_cancel_transaction)
    |> cast_embed(:order_cancel_reject_transaction)
  end
end
