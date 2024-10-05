defmodule ExOanda.CalculatedPositionState do
  @moduledoc """
  Schema for Oanda calculated position state.
  """

  use TypedEctoSchema
  import Ecto.Changeset

  @primary_key false

  typed_embedded_schema do
    field(:instrument, :string)
    field(:net_unrealized_pl, :float)
    field(:long_unrealized_pl, :float)
    field(:short_unrealized_pl, :float)
    field(:margin_used, :float)
  end

  @doc false
  def changeset(struct, params) do
    struct
    |> cast(params, [:instrument, :net_unrealized_pl, :long_unrealized_pl, :short_unrealized_pl, :margin_used])
    |> validate_required([:instrument, :net_unrealized_pl, :long_unrealized_pl, :short_unrealized_pl, :margin_used])
  end
end
