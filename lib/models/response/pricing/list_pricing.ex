defmodule ExOanda.Response.ListPricing do
  @moduledoc """
  Schema for Oanda list pricing response.

  [Oanda Docs](https://developer.oanda.com/rest-live-v20/pricing-ep/)
  """

  use TypedEctoSchema
  import Ecto.Changeset
  alias ExOanda.{
    ClientPrice,
    HomeConversions
  }

  @primary_key false

  typed_embedded_schema do
    embeds_many :prices, ClientPrice
    embeds_many :home_conversions, HomeConversions

    field(:time, :utc_datetime_usec)
  end

  @doc false
  def changeset(struct, params) do
    struct
    |> cast(params, [:time])
    |> cast_embed(:prices)
    |> cast_embed(:home_conversions)
    |> validate_required([:time])
  end
end
