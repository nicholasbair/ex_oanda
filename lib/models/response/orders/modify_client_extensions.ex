defmodule ExOanda.Response.OrderModifyClientExtensions do
  @moduledoc """
  Schema for Oanda modify client extensions response.
  """

  use TypedEctoSchema
  import Ecto.Changeset
  alias ExOanda.{
    OrderClientExtensionsModifyTransaction,
    OrderClientExtensionsModifyRejectTransaction
  }

  @primary_key false

  typed_embedded_schema do
    field(:related_transaction_ids, {:array, :string})
    field(:last_transaction_id, :string)

    embeds_one :order_client_extensions_modify_transaction, OrderClientExtensionsModifyTransaction
    embeds_one :order_client_extensions_modify_reject_transaction, OrderClientExtensionsModifyRejectTransaction
  end

  @doc false
  def changeset(struct, params) do
    struct
    |> cast(params, [:related_transaction_ids, :last_transaction_id])
    |> cast_embed(:order_client_extensions_modify_transaction)
    |> cast_embed(:order_client_extensions_modify_reject_transaction)
  end
end
