defmodule ExOanda.Request.UpdateAccount do
  @moduledoc """
  Schema for Oanda update account request.

  [Oanda Docs](https://developer.oanda.com/rest-live-v20/account-ep/)
  """

  use TypedEctoSchema
  import Ecto.Changeset

  @primary_key false

  typed_embedded_schema do
    field(:alias, :string)
    field(:margin_rate, :float)
  end

  @doc false
  def changeset(struct, params) do
    struct
    |> cast(params, [:alias, :margin_rate])
  end
end
