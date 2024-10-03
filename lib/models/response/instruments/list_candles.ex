defmodule ExOanda.ListCandles do
  @moduledoc """
  Schema for Oanda instruments response.
  """

  use TypedEctoSchema
  import Ecto.Changeset
  alias ExOanda.Price

  @primary_key false

  typed_embedded_schema do
    field(:instrument, :string)
    field(:granularity, :string)

    embeds_many :candles, Candlestick, primary_key: false do
      field(:time, :utc_datetime_usec)
      field(:volume, :integer)
      field(:complete, :boolean)

      embeds_one :bid, Price
      embeds_one :ask, Price
      embeds_one :mid, Price
    end
  end

  @doc false
  def changeset(struct, params) do
    struct
    |> cast(params, [:instrument, :granularity])
    |> cast_embed(:candles, with: &candlestick_changeset/2)
    |> validate_required([:instrument, :granularity])
  end

  defp candlestick_changeset(struct, params) do
    struct
    |> cast(params, [:time, :volume, :complete])
    |> cast_embed(:bid)
    |> cast_embed(:ask)
    |> cast_embed(:mid)
    |> validate_required([:time, :volume, :complete])
  end
end
