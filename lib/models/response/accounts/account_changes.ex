defmodule ExOanda.Response.AccountChanges do
  @moduledoc """
  Schema for Oanda account changes response.

  [Oanda Docs](https://developer.oanda.com/rest-live-v20/account-ep/)
  """

  use TypedEctoSchema
  import Ecto.Changeset
  alias ExOanda.{
    AccountChanges,
    AccountChangesState
  }

  @primary_key false

  typed_embedded_schema do
    embeds_one :changes, AccountChanges
    embeds_one :state, AccountChangesState

    field(:last_transaction_id, :string)
  end

  @doc false
  def changeset(struct, params) do
    struct
    |> cast(params, [:last_transaction_id])
    |> cast_embed(:changes)
    |> cast_embed(:state)
  end
end
