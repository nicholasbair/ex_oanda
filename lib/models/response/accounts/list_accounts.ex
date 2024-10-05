defmodule ExOanda.Response.ListAccounts do
  @moduledoc """
  Schema for Oanda list accounts response.
  """

  use TypedEctoSchema
  import Ecto.Changeset
  alias ExOanda.AccountProperties

  @primary_key false

  typed_embedded_schema do
    embeds_many :accounts, AccountProperties
  end

  @doc false
  def changeset(struct, params) do
    struct
    |> cast(params, [])
    |> cast_embed(:accounts)
  end
end
