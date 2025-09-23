defmodule ExOanda.Response.ListTransactionsIdRange do
  @moduledoc """
  Schema for Oanda list transactions id range response.

  [Oanda Docs](https://developer.oanda.com/rest-live-v20/transaction-ep/)
  """

  use TypedEctoSchema
  import Ecto.Changeset
  alias ExOanda.Transaction

  @primary_key false

  typed_embedded_schema do
    embeds_many :transactions, Transaction
    field(:last_transaction_id, :string)
  end

  @doc false
  def changeset(struct, params) do
    struct
    |> cast(params, [:last_transaction_id])
    |> cast_embed(:transactions)
    |> validate_required([:last_transaction_id])
  end
end
