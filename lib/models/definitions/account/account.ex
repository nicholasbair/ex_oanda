defmodule ExOanda.Account do
  @moduledoc """
  Schema for Oanda account.
  """

  use TypedEctoSchema
  import Ecto.Changeset
  alias ExOanda.{
    GuaranteedStopLossOrderParameters,
    TradeSummary,
    Position,
    Order
  }

  @primary_key false

  typed_embedded_schema do
    field(:id, :string)
    field(:alias, :string)
    field(:currency, :string)
    field(:created_by_user_id, :integer)
    field(:created_time, :utc_datetime_usec)
    field(:resettabled_pl_time, :utc_datetime_usec)
    field(:margin_rate, :float)
    field(:open_trade_count, :integer)
    field(:open_position_count, :integer)
    field(:pending_order_count, :integer)
    field(:hedging_enabled, :boolean)
    field(:unrealized_pl, :float)
    field(:nav, :float)
    field(:margin_used, :float)
    field(:margin_available, :float)
    field(:position_value, :float)
    field(:margin_closeout_unrealized_pl, :float)
    field(:margin_closeout_nav, :float)
    field(:margin_closeout_margin_used, :float)
    field(:margin_closeout_percent, :float)
    field(:margin_closeout_position_value, :float)
    field(:withdrawal_limit, :float)
    field(:margin_call_margin_used, :float)
    field(:margin_call_percent, :float)
    field(:balance, :float)
    field(:pl, :float)
    field(:resettable_pl, :float)
    field(:financing, :float)
    field(:commission, :float)
    field(:dividend_adjustment, :float)
    field(:guaranteed_execution_fees, :float)
    field(:margin_call_enter_time, :utc_datetime_usec)
    field(:margin_call_extension_count, :integer)
    field(:last_margin_call_extension_time, :utc_datetime_usec)
    field(:last_transaction_id, :string)
    field(:guaranteed_stop_loss_order_mode, Ecto.Enum, values: ~w(DISABLED ALLOWED REQUIRED)a)

    embeds_one :guaranteed_stop_loss_order_parameters, GuaranteedStopLossOrderParameters
    embeds_many :trades, TradeSummary
    embeds_many :positions, Position
    embeds_many :orders, Order
  end

  @doc false
  def changeset(struct, params) do
    struct
    |> cast(params, [
      :id, :alias, :currency, :created_by_user_id, :created_time, :resettabled_pl_time,
      :margin_rate, :open_trade_count, :open_position_count, :pending_order_count,
      :hedging_enabled, :unrealized_pl, :nav, :margin_used, :margin_available,
      :position_value, :margin_closeout_unrealized_pl, :margin_closeout_nav,
      :margin_closeout_margin_used, :margin_closeout_percent, :margin_closeout_position_value,
      :withdrawal_limit, :margin_call_margin_used, :margin_call_percent, :balance,
      :pl, :resettable_pl, :financing, :commission, :dividend_adjustment,
      :guaranteed_execution_fees, :margin_call_enter_time, :margin_call_extension_count,
      :last_margin_call_extension_time, :last_transaction_id, :guaranteed_stop_loss_order_mode
    ])
    |> cast_embed(:guaranteed_stop_loss_order_parameters)
    |> cast_embed(:trades)
    |> cast_embed(:positions)
    |> cast_embed(:orders)
    |> validate_required([
      :id, :alias, :currency, :created_by_user_id, :created_time, :resettabled_pl_time,
      :margin_rate, :open_trade_count, :open_position_count, :pending_order_count,
      :hedging_enabled, :unrealized_pl, :nav, :margin_used, :margin_available,
      :position_value, :margin_closeout_unrealized_pl, :margin_closeout_nav,
      :margin_closeout_margin_used, :margin_closeout_percent, :margin_closeout_position_value,
      :withdrawal_limit, :margin_call_margin_used, :margin_call_percent, :balance,
      :pl, :resettable_pl, :financing, :commission, :dividend_adjustment,
      :guaranteed_execution_fees, :margin_call_enter_time, :margin_call_extension_count,
      :last_margin_call_extension_time, :last_transaction_id, :guaranteed_stop_loss_order_mode
    ])
  end
end
