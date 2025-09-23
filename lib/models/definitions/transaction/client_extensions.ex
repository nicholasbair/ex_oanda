defmodule ExOanda.ClientExtensions do
  @moduledoc """
  Schema for Oanda client extension.

  [Oanda Docs](https://developer.oanda.com/rest-live-v20/transaction-df/)
  """

  use TypedEctoSchema
  import Ecto.Changeset

  @primary_key false

  typed_embedded_schema do
    field(:id, :string)
    field(:tag, :string)
    field(:comment, :string)
  end

  @doc false
  def changeset(struct, params) do
    struct
    |> cast(params, [:id, :tag, :comment])
  end
end
