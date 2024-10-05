defmodule ExOanda.ClientPrice do
  @moduledoc """
  Schema for Oanda client price.
  """

  use TypedEctoSchema
  import Ecto.Changeset
  alias ExOanda.{
    PriceBucket,
    Type.Atom
  }

  @primary_key false

  typed_embedded_schema do
    field(:type, Atom, default: :PRICE)
    field(:instrument, :string)
    field(:time, :utc_datetime_usec)
    field(:tradeable, :boolean)
    field(:closeout_bid, :float)
    field(:closeout_ask, :float)

    embeds_many :bids, PriceBucket
    embeds_many :asks, PriceBucket
  end

  @doc false
  def changeset(struct, params) do
    struct
    |> cast(params, [:type, :instrument, :time, :tradeable, :closeout_bid, :closeout_ask])
    |> cast_embed(:bids)
    |> cast_embed(:asks)
    |> validate_required([:type, :instrument, :time, :tradeable, :closeout_bid, :closeout_ask])
  end
end
