defmodule ExOanda.MarketIfTouchedOrderRejectTransaction do
  @moduledoc """
  A MarketIfTouchedOrderRejectTransaction represents the rejection of the creation of a
  MarketIfTouched Order.

  [Oanda Docs](https://developer.oanda.com/rest-live-v20/transaction-df/)
  """

  use TypedEctoSchema
  import Ecto.Changeset
  alias ExOanda.Type.Atom

  alias ExOanda.{
    ClientExtensions,
    TakeProfitDetails,
    StopLossDetails,
    TrailingStopLossDetails,
    GuaranteedStopLossDetails
  }

  @primary_key false

  embedded_schema do
    field(:id, :string)
    field(:time, :utc_datetime_usec)
    field(:user_id, :integer)
    field(:account_id, :string)
    field(:batch_id, :string)
    field(:request_id, :string)
    field(:type, Atom, default: :MARKET_IF_TOUCHED_ORDER_REJECT)
    field(:instrument, Atom)
    field(:units, :float)
    field(:price, :float)
    field(:price_bound, :float)
    field(:time_in_force, Ecto.Enum, values: ~w(GTC GTD GFD FOK IOC)a)
    field(:gtd_time, :utc_datetime_usec)
    field(:position_fill, :string, default: "DEFAULT")
    field(:trigger_condition, Ecto.Enum, values: ~w(DEFAULT INVERSE BID ASK MID)a)
    field(:reason, :string)
    field(:reject_reason, :string)
    field(:initial_market_price, :float)

    embeds_one :client_extensions, ClientExtensions
    embeds_one :take_profit_on_fill, TakeProfitDetails
    embeds_one :stop_loss_on_fill, StopLossDetails
    embeds_one :trailing_stop_loss_on_fill, TrailingStopLossDetails
    embeds_one :guaranteed_stop_loss_on_fill, GuaranteedStopLossDetails
  end

  def changeset(struct, data) do
    struct
    |> cast(data, [
      :id,
      :time,
      :user_id,
      :account_id,
      :batch_id,
      :request_id,
      :type,
      :instrument,
      :units,
      :price,
      :price_bound,
      :time_in_force,
      :gtd_time,
      :position_fill,
      :trigger_condition,
      :reason,
      :reject_reason,
      :initial_market_price
    ])
    |> cast_embed(:client_extensions)
    |> cast_embed(:take_profit_on_fill)
    |> cast_embed(:stop_loss_on_fill)
    |> cast_embed(:trailing_stop_loss_on_fill)
    |> cast_embed(:guaranteed_stop_loss_on_fill)
    |> validate_required([
      :id,
      :time,
      :user_id,
      :account_id,
      :batch_id,
      :type,
      :reject_reason
    ])
  end
end
