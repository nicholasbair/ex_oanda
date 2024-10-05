defmodule ExOanda.Response.FindAccount do
  @moduledoc """
  Schema for Oanda find account response.
  """

  use TypedEctoSchema
  import Ecto.Changeset
  alias ExOanda.{
    Account
  }

  @primary_key false

  typed_embedded_schema do
    embeds_one :account, Account
    field(:last_transaction_id, :string)
  end

  @doc false
  def changeset(struct, params) do
    struct
    |> cast(params, [:last_transaction_id])
    |> cast_embed(:account)
    |> validate_required([:last_transaction_id])
  end
end
