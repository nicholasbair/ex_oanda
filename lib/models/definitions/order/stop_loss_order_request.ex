defmodule ExOanda.StopLossOrderRequest do
  @moduledoc """
  Schema for Oanda stop loss order request.

  [Oanda Docs](https://developer.oanda.com/rest-live-v20/order-df/#StopLossOrderRequest)
  """

  use TypedEctoSchema
  import Ecto.Changeset

  alias ExOanda.ClientExtensions

  @primary_key false

  typed_embedded_schema do
    field(:type, Ecto.Enum, values: [:STOP_LOSS], default: :STOP_LOSS)
    field(:trade_id, :string)
    field(:client_trade_id, :string)
    field(:price, :float)
    field(:distance, :float)
    field(:time_in_force, Ecto.Enum, values: ~w(GTC GTD GFD)a, default: :GTC)
    field(:gtd_time, :utc_datetime_usec)
    field(:trigger_condition, Ecto.Enum, values: ~w(DEFAULT INVERSE BID ASK MID)a, default: :DEFAULT)

    embeds_one :client_extensions, ClientExtensions
  end

  @doc false
  def changeset(struct, params) do
    struct
    |> cast(params, [
      :type,
      :trade_id,
      :client_trade_id,
      :distance,
      :price,
      :time_in_force,
      :gtd_time,
      :trigger_condition
    ])
    |> validate_inclusion(:time_in_force, ~w(GTC GTD GFD)a)
    |> validate_inclusion(:trigger_condition, ~w(DEFAULT INVERSE BID ASK MID)a)
    |> validate_required([:trade_id])
    |> validate_price_or_distance()
    |> cast_embed(:client_extensions)
  end

  defp validate_price_or_distance(changeset) do
    price = get_field(changeset, :price)
    distance = get_field(changeset, :distance)

    cond do
      price && distance ->
        add_error(changeset, :base, "only one of price or distance may be specified")
      price || distance ->
        changeset
      true ->
        add_error(changeset, :base, "either price or distance must be specified")
    end
  end
end
