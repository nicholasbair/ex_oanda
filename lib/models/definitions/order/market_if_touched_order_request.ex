defmodule ExOanda.MarketIfTouchedOrderRequest do
  @moduledoc """
  Schema for Oanda market-if-touched order request.

  [Oanda Docs](https://developer.oanda.com/rest-live-v20/order-df/#MarketIfTouchedOrderRequest)
  """

  use TypedEctoSchema
  import Ecto.Changeset

  alias ExOanda.{
    ClientExtensions,
    GuaranteedStopLossDetails,
    StopLossDetails,
    TakeProfitDetails,
    TrailingStopLossDetails,
    Type.Atom
  }

  @primary_key false

  typed_embedded_schema do
    field(:type, Ecto.Enum, values: [:MARKET_IF_TOUCHED], default: :MARKET_IF_TOUCHED)
    field(:instrument, Atom)
    field(:units, :integer)
    field(:price, :float)
    field(:price_bound, :float)
    field(:time_in_force, Ecto.Enum, values: ~w(GTC GTD GFD FOK IOC)a, default: :GTC)
    field(:gtd_time, :utc_datetime_usec)
    field(:position_fill, Ecto.Enum, values: ~w(DEFAULT REDUCE_ONLY)a, default: :DEFAULT)
    field(:trigger_condition, Ecto.Enum, values: ~w(DEFAULT INVERSE BID ASK MID)a, default: :DEFAULT)

    embeds_one :client_extensions, ClientExtensions
    embeds_one :take_profit_on_fill, TakeProfitDetails
    embeds_one :stop_loss_on_fill, StopLossDetails
    embeds_one :guaranteed_stop_loss_on_fill, GuaranteedStopLossDetails
    embeds_one :trailing_stop_loss_on_fill, TrailingStopLossDetails
    embeds_one :trade_client_extensions, ClientExtensions
  end

  @doc false
  def changeset(struct, params) do
    struct
    |> cast(params, [
      :type,
      :instrument,
      :units,
      :price,
      :price_bound,
      :time_in_force,
      :gtd_time,
      :position_fill,
      :trigger_condition
    ])
    |> validate_inclusion(:time_in_force, ~w(GTC GTD GFD FOK IOC)a)
    |> validate_inclusion(:position_fill, ~w(DEFAULT REDUCE_ONLY)a)
    |> validate_inclusion(:trigger_condition, ~w(DEFAULT INVERSE BID ASK MID)a)
    |> validate_required([:instrument, :units, :price])
    |> cast_embed(:client_extensions)
    |> cast_embed(:take_profit_on_fill)
    |> cast_embed(:stop_loss_on_fill)
    |> cast_embed(:guaranteed_stop_loss_on_fill)
    |> cast_embed(:trailing_stop_loss_on_fill)
    |> cast_embed(:trade_client_extensions)
  end
end
