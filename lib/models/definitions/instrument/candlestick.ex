defmodule ExOanda.Candlestick do
  @moduledoc """
  Schema for Oanda candlestick.

  [Oanda Docs](https://developer.oanda.com/rest-live-v20/instrument-df/)
  """

  use TypedEctoSchema
  import Ecto.Changeset
  alias ExOanda.CandlestickData

  @primary_key false

  typed_embedded_schema do
    field(:time, :utc_datetime_usec)
    field(:volume, :integer)
    field(:complete, :boolean)

    embeds_one :bid, CandlestickData
    embeds_one :ask, CandlestickData
    embeds_one :mid, CandlestickData
  end

  @doc false
  def changeset(struct, params) do
    struct
    |> cast(params, [:time, :volume, :complete])
    |> cast_embed(:bid)
    |> cast_embed(:ask)
    |> cast_embed(:mid)
    |> validate_required([:time, :volume, :complete])
  end
end
