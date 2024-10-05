defmodule ExOanda.InstrumentCommission do
  @moduledoc """
  Schema for Oanda instrument commission.
  """

  use TypedEctoSchema
  import Ecto.Changeset

  @primary_key false

  typed_embedded_schema do
    field(:commission, :float)
    field(:units_traded, :float)
    field(:minimum_commission, :float)
  end

  @doc false
  def changeset(struct, params) do
    struct
    |> cast(params, [:commission, :units_traded, :minimum_commission])
    |> validate_required([:commission, :units_traded, :minimum_commission])
  end
end
