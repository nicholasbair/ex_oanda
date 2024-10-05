defmodule ExOanda.Response.ListCandles do
  @moduledoc """
  Schema for Oanda instruments response.
  """

  use TypedEctoSchema
  import Ecto.Changeset
  alias ExOanda.Candlestick

  @primary_key false

  typed_embedded_schema do
    field(:instrument, :string)
    field(:granularity, Ecto.Enum, values: ~w(S5 S10 S15 S30 M1 M2 M3 M4 M5 M10 M15 M30 H1 H2 H3 H4 H6 H8 H12 D W M)a)

    embeds_many :candles, Candlestick
  end

  @doc false
  def changeset(struct, params) do
    struct
    |> cast(params, [:instrument, :granularity])
    |> cast_embed(:candles)
    |> validate_required([:instrument, :granularity])
  end
end
