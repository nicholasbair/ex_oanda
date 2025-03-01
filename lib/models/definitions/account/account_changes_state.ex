defmodule ExOanda.AccountChangesState do
  @moduledoc """
  Schema for Oanda account changes state.
  """

  use TypedEctoSchema
  import Ecto.Changeset
  alias ExOanda.{
    CalculatedPositionState,
    CalculatedTradeState,
    DynamicOrderState
  }

  @primary_key false

  typed_embedded_schema do
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

    embeds_many :orders, DynamicOrderState
    embeds_many :trades, CalculatedTradeState
    embeds_many :positions, CalculatedPositionState
  end

  @doc false
  def changeset(struct, params) do
    struct
    |> cast(params, [
      :unrealized_pl,
      :nav,
      :margin_used,
      :margin_available,
      :position_value,
      :margin_closeout_unrealized_pl,
      :margin_closeout_nav,
      :margin_closeout_margin_used,
      :margin_closeout_percent,
      :margin_closeout_position_value,
      :withdrawal_limit,
      :margin_call_margin_used,
      :margin_call_percent,
      :balance,
      :pl,
      :resettable_pl,
      :financing,
      :commission,
      :dividend_adjustment,
      :guaranteed_execution_fees,
      :margin_call_enter_time,
      :margin_call_extension_count,
      :last_margin_call_extension_time,
      :last_transaction_id
    ])
    |> cast_embed(:orders)
    |> cast_embed(:trades)
    |> cast_embed(:positions)
    |> validate_required([
      :unrealized_pl,
      :nav,
      :margin_used,
      :margin_available,
      :position_value,
      :margin_closeout_unrealized_pl,
      :margin_closeout_nav,
      :margin_closeout_margin_used,
      :margin_closeout_percent,
      :withdrawal_limit,
      :margin_call_margin_used,
      :margin_call_percent,
      :balance,
      :pl,
      :resettable_pl
    ])
  end
end
