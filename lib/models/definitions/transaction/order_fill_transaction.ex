defmodule ExOanda.OrderFillTransaction do
  @moduledoc """
  Schema for Oanda order fill transaction.
  """

  use TypedEctoSchema
  import Ecto.Changeset
  alias ExOanda.{
    TradeOpened,
    TradeReduce,
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
    field(:type, Atom, default: :ORDER_FILL)
    field(:order_id, :string)
    field(:instrument, :string)
    field(:units, :integer)
    field(:client_order_id, :string)
    field(:full_vwap, :float)
    field(:full_price, :float)
    field(:reason, Ecto.Enum, values: [
      :LIMIT_ORDER,
      :STOP_ORDER,
      :MARKET_IF_TOUCHED_ORDER,
      :TAKE_PROFIT_ORDER,
      :STOP_LOSS_ORDER,
      :GUARANTEED_STOP_LOSS_ORDER,
      :TRAILING_STOP_LOSS_ORDER,
      :MARKET_ORDER,
      :MARKET_ORDER_TRADE_CLOSE,
      :MARKET_ORDER_POSITION_CLOSEOUT,
      :MARKET_ORDER_MARGIN_CLOSEOUT,
      :MARKET_ORDER_DELAYED_TRADE_CLOSE,
      :FIXED_PRICE_ORDER,
      :FIXED_PRICE_ORDER_PLATFORM_ACCOUNT_MIGRATION,
      :FIXED_PRICE_ORDER_DIVISION_ACCOUNT_MIGRATION,
      :FIXED_PRICE_ORDER_ADMINISTRATIVE_ACTION
    ])
    field(:pl, :float)
    field(:quote_pl, :float)
    field(:financing, :float)
    field(:base_financing, :float)
    field(:quote_financing, :float)
    field(:commission, :float)
    field(:guaranteed_execution_fee, :float)
    field(:quote_guaranteed_execution_fee, :float)
    field(:account_balance, :float)
    field(:half_spread_cost, :float)

    embeds_one :trade_opened, TradeOpened
    embeds_one :trade_reduced, TradeReduce
    embeds_many :trades_closed, TradeReduce
  end

  @doc false
  def changeset(struct, params) do
    struct
    |> cast(params, [
      :id, :time, :user_id, :account_id, :batch_id, :request_id, :type, :order_id,
      :instrument, :units, :client_order_id, :full_vwap, :full_price, :reason, :pl,
      :quote_pl, :financing, :base_financing, :quote_financing, :commission,
      :guaranteed_execution_fee, :quote_guaranteed_execution_fee, :account_balance,
      :half_spread_cost
    ])
    |> cast_embed(:trade_opened)
    |> cast_embed(:trade_reduced)
    |> cast_embed(:trades_closed)
    |> validate_required([
      :id, :time, :user_id, :account_id, :batch_id, :request_id, :type, :order_id,
      :instrument, :units, :client_order_id, :full_vwap, :full_price, :reason, :pl,
      :quote_pl, :financing, :base_financing, :quote_financing, :commission,
      :guaranteed_execution_fee, :quote_guaranteed_execution_fee, :account_balance,
      :half_spread_cost
    ])
  end
end
