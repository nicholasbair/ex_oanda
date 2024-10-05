defmodule ExOanda.CandlestickData do
  @moduledoc """
  Schema for Oanda candlestick data.
  """

  use TypedEctoSchema
  import Ecto.Changeset

  @primary_key false

  typed_embedded_schema do
    field(:o, :float)
    field(:h, :float)
    field(:l, :float)
    field(:c, :float)
  end

  @doc false
  def changeset(struct, params) do
    struct
    |> cast(params, [:o, :h, :l, :c])
    |> validate_required([:o, :h, :l, :c])
  end
end
