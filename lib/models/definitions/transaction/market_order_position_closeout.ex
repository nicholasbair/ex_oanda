defmodule ExOanda.MarketOrderPositionCloseout do
  @moduledoc """
  Schema for Oanda market order position closeout.
  """

  use TypedEctoSchema
  import Ecto.Changeset
  alias ExOanda.Type.Atom
  @primary_key false

  typed_embedded_schema do
    field(:instrument, Atom)
    field(:units, :string)
  end

  @doc false
  def changeset(struct, params) do
    struct
    |> cast(params, [:instrument, :units])
  end
end
