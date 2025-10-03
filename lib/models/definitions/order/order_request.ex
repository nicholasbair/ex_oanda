defmodule ExOanda.OrderRequest do
  @moduledoc """
  Schema for Oanda order request.

  [Oanda Docs](https://developer.oanda.com/rest-live-v20/order-df/)
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
    field(:type, Ecto.Enum, values: ~w(MARKET LIMIT STOP MARKET_IF_TOUCHED TAKE_PROFIT STOP_LOSS GUARANTEED_STOP_LOSS TRAILING_STOP_LOSS)a, default: :MARKET)
    field(:instrument, Atom)
    field(:units, :integer)
    field(:price, :float)
    field(:time_in_force, Ecto.Enum, values: ~w(GTC GTD GFD FOK IOC)a)
    field(:price_bound, :float)
    field(:trade_id, :string)
    field(:client_trade_id, :string)
    field(:position_fill, Ecto.Enum, values: ~w(DEFAULT REDUCE_ONLY)a)
    field(:distance, :float)
    field(:gtd_time, :utc_datetime_usec)
    field(:trigger_condition, Ecto.Enum, values: ~w(DEFAULT INVERSE BID ASK MID)a)

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
      :time_in_force,
      :price_bound,
      :trade_id,
      :client_trade_id,
      :position_fill,
      :distance,
      :gtd_time,
      :trigger_condition
    ])
    |> validate_inclusion(:type, ~w(MARKET LIMIT STOP MARKET_IF_TOUCHED TAKE_PROFIT STOP_LOSS GUARANTEED_STOP_LOSS TRAILING_STOP_LOSS)a)
    |> validate_inclusion(:time_in_force, ~w(GTC GTD GFD FOK IOC)a)
    |> validate_inclusion(:position_fill, ~w(DEFAULT REDUCE_ONLY)a)
    |> validate_inclusion(:trigger_condition, ~w(DEFAULT INVERSE BID ASK MID)a)
    |> validate_required([:instrument, :units])
    |> cast_embed(:client_extensions)
    |> cast_embed(:take_profit_on_fill)
    |> cast_embed(:stop_loss_on_fill)
    |> cast_embed(:guaranteed_stop_loss_on_fill)
    |> cast_embed(:trailing_stop_loss_on_fill)
    |> cast_embed(:trade_client_extensions)
  end
end
