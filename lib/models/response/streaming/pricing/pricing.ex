defmodule ExOanda.Response.Pricing do
  @moduledoc """
  Schema for Oanda streaming pricing response.
  """

  use TypedEctoSchema
  import Ecto.Changeset

  @primary_key false

  typed_embedded_schema do
    field(:instrument, :string)
    field(:status, Ecto.Enum, values: [:tradeable, :non_tradeable, :invalid])
    field(:time, :utc_datetime_usec)
    field(:closeout_ask, :float)
    field(:closeout_bid, :float)

    embeds_many :asks, Ask, primary_key: false do
      field(:liquidity, :integer)
      field(:price, :float)
    end

    embeds_many :bids, Bid, primary_key: false do
      field(:liquidity, :integer)
      field(:price, :float)
    end
  end

  @doc false
  def changeset(struct, params) do
    struct
    |> cast(params, [
      :instrument,
      :status,
      :time,
      :closeout_ask,
      :closeout_bid,
    ])
    |> cast_embed(:asks, with: &price_changeset/2)
    |> cast_embed(:bids, with: &price_changeset/2)
  end

  defp price_changeset(struct, params) do
    struct
    |> cast(params, [:liquidity, :price])
  end
end
