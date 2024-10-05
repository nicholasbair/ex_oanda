defmodule ExOanda.GuaranteedStopLossOrderParameters do
  @moduledoc """
  Schema for Oanda guaranteed stop loss order parameters.
  """

  use TypedEctoSchema
  import Ecto.Changeset

  @primary_key false

  typed_embedded_schema do
    field(:mutability_market_open, Ecto.Enum, values: [:FIXED, :REPLACEABLE, :CANCELABLE, :PRICE_WIDEN_ONLY])
    field(:mutability_market_halted, Ecto.Enum, values: [:FIXED, :REPLACEABLE, :CANCELABLE, :PRICE_WIDEN_ONLY])
  end

  @doc false
  def changeset(struct, params) do
    struct
    |> cast(params, [:mutability_market_open, :mutability_market_halted])
    |> validate_required([:mutability_market_open, :mutability_market_halted])
  end
end
