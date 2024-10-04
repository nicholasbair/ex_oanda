defmodule ExOanda.ListPricing do
  @moduledoc """
  Schema for Oanda list pricing response.
  """

  use TypedEctoSchema
  import Ecto.Changeset
  alias ExOanda.PriceBucket

  @primary_key false

  typed_embedded_schema do
    embeds_many :prices, ClientPrice, primary_key: false do
      field(:type, :string)
      field(:instrument, :string)
      field(:time, :utc_datetime_usec)
      field(:tradeable, :boolean)
      field(:closeout_bid, :float)
      field(:closeout_ask, :float)

      embeds_many :bids, PriceBucket
      embeds_many :asks, PriceBucket
    end

    embeds_many :home_conversions, HomeConversion, primary_key: false do
      field(:currency, :string)
      field(:account_gain, :float)
      field(:account_loss, :float)
      field(:position_value, :float)
    end

    field(:time, :utc_datetime_usec)
  end

  @doc false
  def changeset(struct, params) do
    struct
    |> cast(params, [:time])
    |> cast_embed(:prices, with: &client_price_changeset/2)
    |> cast_embed(:home_conversions, with: &home_conversion_changeset/2)
    |> validate_required([:time])
  end

  defp client_price_changeset(struct, params) do
    struct
    |> cast(params, [:type, :instrument, :time, :tradeable, :closeout_bid, :closeout_ask])
    |> cast_embed(:bids)
    |> cast_embed(:asks)
    |> validate_required([:type, :instrument, :time, :tradeable, :closeout_bid, :closeout_ask])
  end

  defp home_conversion_changeset(struct, params) do
    struct
    |> cast(params, [:currency, :account_gain, :account_loss, :position_value])
    |> validate_required([:currency, :account_gain, :account_loss, :position_value])
  end


end
