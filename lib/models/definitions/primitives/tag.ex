defmodule ExOanda.Tag do
  @moduledoc """
  Schema for Oanda tag.
  """

  use TypedEctoSchema
  import Ecto.Changeset

  @primary_key false

  typed_embedded_schema do
    field(:type, :string)
    field(:name, :string)
  end

  @doc false
  def changeset(struct, params) do
    struct
    |> cast(params, [:type, :name])
    |> validate_required([:type, :name])
  end
end
