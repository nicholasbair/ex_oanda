defmodule ExOanda.MarketOrderRejectTransaction do
  @moduledoc """
  Schema for Oanda market order reject transaction.
  """

  use TypedEctoSchema
  import Ecto.Changeset
  alias ExOanda.{
    ClientExtensions,
    MarketOrderPositionCloseout,
    MarketOrderMarginCloseout,
    MarketOrderTradeClose,
    MarketOrderDelayedTradeCloseout,
    TakeProfitDetails,
    StopLossDetails,
    TrailingStopLossDetails,
    GuaranteedStopLossDetails,
    Type.Atom
  }

  @primary_key false

  typed_embedded_schema do
    field(:id, :string)
    field(:time, :utc_datetime_usec)
    field(:user_id, :integer)
    field(:account_id, :string)
    field(:batch_id, :string)
    field(:request_id, :string)
    field(:type, Atom, default: :MARKET_ORDER)
    field(:instrument, :string)
    field(:units, :float)
    field(:time_in_force, Ecto.Enum, values: ~w(GTC GTD GFD FOK IOC)a)
    field(:price_bound, :float)
    field(:position_fill, Ecto.Enum, values: ~w(DEFAULT REDUCE_FIRST REDUCE_ONLY OPEN_ONLY)a)
    field(:reason, Ecto.Enum, values: ~w(CLIENT_ORDER TRADE_CLOSE POSITION_CLOSEOUT MARGIN_CLOSEOUT DELAYED_TRADE_CLOSE)a)

    embeds_one :trade_close, MarketOrderTradeClose
    embeds_one :long_position_closeout, MarketOrderPositionCloseout
    embeds_one :short_position_closeout, MarketOrderPositionCloseout
    embeds_one :margin_closeout, MarketOrderMarginCloseout
    embeds_one :delayed_trade_close, MarketOrderDelayedTradeCloseout
    embeds_one :client_extensions, ClientExtensions
    embeds_one :take_profit_on_fill, TakeProfitDetails
    embeds_one :stop_loss_on_fill, StopLossDetails
    embeds_one :trailing_stop_loss_on_fill, TrailingStopLossDetails
    embeds_one :guaranteed_stop_loss_on_fill, GuaranteedStopLossDetails
    embeds_one :trade_client_extensions, ClientExtensions
  end

  @doc false
  def changeset(struct, params) do
    struct
    |> cast(params, [
      :id,
      :time,
      :user_id,
      :account_id,
      :batch_id,
      :request_id,
      :type,
      :instrument,
      :units,
      :time_in_force,
      :price_bound,
      :position_fill,
      :reason,
      :trade_close,
      :long_position_closeout,
      :short_position_closeout,
      :margin_closeout,
      :delayed_trade_close,
      :client_extensions,
      :take_profit_on_fill,
      :stop_loss_on_fill,
      :trailing_stop_loss_on_fill,
      :guaranteed_stop_loss_on_fill,
      :trade_client_extensions
    ])
    |> cast_embed(:trade_close)
    |> cast_embed(:long_position_closeout)
    |> cast_embed(:short_position_closeout)
    |> cast_embed(:margin_closeout)
    |> cast_embed(:delayed_trade_close)
    |> cast_embed(:client_extensions)
    |> cast_embed(:take_profit_on_fill)
    |> cast_embed(:stop_loss_on_fill)
    |> cast_embed(:trailing_stop_loss_on_fill)
    |> cast_embed(:guaranteed_stop_loss_on_fill)
    |> cast_embed(:trade_client_extensions)
  end
end
