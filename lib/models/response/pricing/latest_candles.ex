defmodule ExOanda.Response.LatestCandles do
  @moduledoc """
  Schema for Oanda list candles response.
  """

  use TypedEctoSchema
  import Ecto.Changeset
  alias ExOanda.Response.ListCandles

  @primary_key false

  typed_embedded_schema do
    embeds_one :latest_candles, ListCandles
  end

  @doc false
  def changeset(struct, params) do
    struct
    |> cast(params, [])
    |> cast_embed(:latest_candles)
  end
end
