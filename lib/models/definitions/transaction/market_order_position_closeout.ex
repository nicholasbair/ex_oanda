defmodule ExOanda.MarketOrderPositionCloseout do
  @moduledoc """
  Schema for Oanda market order position closeout.
  """

  use TypedEctoSchema
  import Ecto.Changeset

  @primary_key false

  typed_embedded_schema do
    field(:instrument, :string)
    field(:units, :integer)
  end

  @doc false
  def changeset(struct, params) do
    struct
    |> cast(params, [:instrument, :units])
  end
end
