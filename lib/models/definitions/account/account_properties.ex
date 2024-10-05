defmodule ExOanda.AccountProperties do
  @moduledoc """
  Schema for Oanda account properties.
  """

  use TypedEctoSchema
  import Ecto.Changeset

  @primary_key false

  typed_embedded_schema do
    field(:id, :string)
    field(:mt4_account_id, :integer)
    field(:tags, {:array, :string}, default: [])
  end

  @doc false
  def changeset(struct, params) do
    struct
    |> cast(params, [:id, :mt4_account_id, :tags])
    |> validate_required([:id])
  end
end
