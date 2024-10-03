defmodule ExOanda.PositionSide do
  @moduledoc """
  Schema for Oanda position side.
  """

  use TypedEctoSchema
  import Ecto.Changeset

  @primary_key false

  typed_embedded_schema do
    field(:units, :integer)
    field(:average_price, :float)
    field(:trade_ids, {:array, :string}, default: [])
    field(:pl, :float)
    field(:unrealized_pl, :float)
    field(:resettable_pl, :float)
    field(:financing, :float)
    field(:commission, :float)
    field(:dividend_adjustment, :float)
    field(:guaranteed_execution_fees, :float)
  end

  @doc false
  def changeset(struct, params) do
    struct
    |> cast(params, [
      :units, :average_price, :trade_ids, :pl, :unrealized_pl, :resettable_pl,
      :financing, :commission, :dividend_adjustment, :guaranteed_execution_fees
    ])
    |> validate_required([
      :units, :average_price, :trade_ids, :pl, :unrealized_pl, :resettable_pl,
      :financing, :commission, :dividend_adjustment, :guaranteed_execution_fees
    ])
  end
end
