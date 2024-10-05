defmodule ExOanda.ClientExtensions do
  @moduledoc """
  Schema for Oanda client extension.
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
    |> validate_required([:id])
  end
end
