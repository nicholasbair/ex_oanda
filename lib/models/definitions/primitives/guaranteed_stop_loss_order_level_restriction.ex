defmodule ExOanda.GuaranteedStopLossOrderLevelRestriction do
  @moduledoc """
  Schema for Oanda guaranteed stop loss order level restriction.
  """

  use TypedEctoSchema
  import Ecto.Changeset

  @primary_key false

  typed_embedded_schema do
    field(:volume, :integer)
    field(:price_range, :float)
  end

  @doc false
  def changeset(struct, params) do
    struct
    |> cast(params, [:volume, :price_range])
    |> validate_required([:volume, :price_range])
  end
end
