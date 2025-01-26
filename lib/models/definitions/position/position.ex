defmodule ExOanda.Position do
  @moduledoc """
  Schema for position
  """

  use TypedEctoSchema
  import Ecto.Changeset
  alias ExOanda.{
    PositionSide,
    Type.Atom
  }

  @primary_key false

  typed_embedded_schema do
    field(:instrument, Atom)
    field(:pl, :float)
    field(:unrealized_pl, :float)
    field(:margin_used, :float)
    field(:resettable_pl, :float)
    field(:financing, :float)
    field(:commission, :float)
    field(:dividend_adjustment, :float)
    field(:guaranteed_execution_fees, :float)

    embeds_one :long, PositionSide
    embeds_one :short, PositionSide
  end

  @doc false
  def changeset(struct, params) do
    struct
    |> cast(params, [
      :instrument, :pl, :unrealized_pl, :margin_used, :resettable_pl,
      :financing, :commission, :dividend_adjustment, :guaranteed_execution_fees
    ])
    |> validate_required([
      :instrument, :pl, :resettable_pl,
      :financing, :commission, :dividend_adjustment, :guaranteed_execution_fees
    ])
    |> cast_embed(:long)
    |> cast_embed(:short)
  end
end
