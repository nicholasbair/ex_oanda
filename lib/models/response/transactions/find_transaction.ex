defmodule ExOanda.Response.FindTransaction do
  @moduledoc """
  Schema for Oanda find transaction response.
  """

  use TypedEctoSchema
  import Ecto.Changeset
  alias ExOanda.Transaction

  @primary_key false

  typed_embedded_schema do
    embeds_one :transaction, Transaction
    field(:last_transaction_id, :string)
  end

  @doc false
  def changeset(struct, params) do
    struct
    |> cast(params, [:last_transaction_id])
    |> cast_embed(:transaction)
    |> validate_required([:last_transaction_id])
  end
end
