defmodule ExOanda.Response.AccountSummary do
  @moduledoc """
  Schmea for Oanda account summary response.

  [Oanda Docs](https://developer.oanda.com/rest-live-v20/account-ep/)
  """

  use TypedEctoSchema
  import Ecto.Changeset
  alias ExOanda.AccountSummary

  @primary_key false

  typed_embedded_schema do
    embeds_one :account, AccountSummary
    field(:last_transaction_id, :string)
  end

  @doc false
  def changeset(struct, params) do
    struct
    |> cast(params, [:last_transaction_id])
    |> cast_embed(:account)
  end
end
