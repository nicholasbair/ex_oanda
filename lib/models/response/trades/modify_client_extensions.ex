defmodule ExOanda.Response.TradeModifyClientExtensions do
  @moduledoc """
  Schema for Oanda modify client extensions response.
  """

  use TypedEctoSchema
  import Ecto.Changeset
  alias ExOanda.{
    TradeClientExtensionsModifyTransaction,
    TradeClientExtensionsModifyRejectTransaction
  }

  @primary_key false

  typed_embedded_schema do
    field(:related_transaction_ids, {:array, :string})
    field(:last_transaction_id, :string)
    field(:error_code, :string)
    field(:error_message, :string)

    embeds_one :trade_client_extensions_modify_transaction, TradeClientExtensionsModifyTransaction
    embeds_one :trade_client_extensions_modify_reject_transaction, TradeClientExtensionsModifyRejectTransaction
  end

  @doc false
  def changeset(struct, params) do
    struct
    |> cast(params, [:related_transaction_ids, :last_transaction_id, :error_code, :error_message])
    |> cast_embed(:trade_client_extensions_modify_transaction)
    |> cast_embed(:trade_client_extensions_modify_reject_transaction)
  end
end
