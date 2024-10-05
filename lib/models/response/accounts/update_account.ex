defmodule ExOanda.Response.UpdateAccount do
  @moduledoc """
  Schema for Oanda update account response.
  """

  use TypedEctoSchema
  import Ecto.Changeset
  alias ExOanda.{
    ClientConfigureTransaction,
    ClientConfigureRejectTransaction
  }

  @primary_key false

  typed_embedded_schema do
    embeds_one :client_configure_transaction, ClientConfigureTransaction
    embeds_one :client_configure_reject_transaction, ClientConfigureRejectTransaction

    field(:last_transaction_id, :string)
  end

  @doc false
  def changeset(struct, params) do
    struct
    |> cast(params, [:last_transaction_id])
    |> cast_embed(:client_configure_transaction)
    |> cast_embed(:client_configure_reject_transaction)
  end
end
