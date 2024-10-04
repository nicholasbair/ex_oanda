defmodule ExOanda.PriceBucket do
  @moduledoc """
  Schema for Oanda price bucket.
  """

  use TypedEctoSchema
  import Ecto.Changeset

  @primary_key false

  typed_embedded_schema do
    field(:price, :float)
    field(:liquidity, :integer)
  end

  @doc false
  def changeset(struct, params) do
    struct
    |> cast(params, [:price, :liquidity])
    |> validate_required([:price, :liquidity])
  end
end
