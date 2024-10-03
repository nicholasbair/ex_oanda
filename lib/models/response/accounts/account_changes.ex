defmodule ExOanda.AccountChanges do
  @moduledoc """
  Schema for Oanda account changes response.
  """

  use TypedEctoSchema
  import Ecto.Changeset
  alias ExOanda.{
    Order,
    Position,
    TradeSummary,
    Transaction
  }

  @primary_key false

  typed_embedded_schema do
    embeds_many :changes, Change, primary_key: false do
      embeds_many :orders_created, Order
      embeds_many :orders_cancelled, Order
      embeds_many :orders_filled, Order
      embeds_many :orders_triggered, Order

      embeds_many :trades_opened, TradeSummary
      embeds_many :trades_reduced, TradeSummary
      embeds_many :trades_closed, TradeSummary

      embeds_many :positions, Position

      embeds_many :transactions, Transaction
    end

    embeds_one :state, AccountState, primary_key: false do
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

      embeds_many :orders, OrderState, primary_key: false do
        field(:id, :string)
        field(:trailing_stop_value, :float)
        field(:trigger_distance, :float)
        field(:is_trigger_distance_exact, :boolean)
      end

      embeds_many :trades, TradeState, primary_key: false do
        field(:id, :string)
        field(:unrealized_pl, :float)
        field(:margin_used, :float)
      end

      embeds_many :positions, PositionState, primary_key: false do
        field(:instrument, :string)
        field(:net_unrealized_pl, :float)
        field(:long_unrealized_pl, :float)
        field(:short_unrealized_pl, :float)
        field(:margin_used, :float)
      end
    end

    field(:last_transaction_id, :string)
  end

  @doc false
  def changeset(struct, params) do
    struct
    |> cast(params, [:last_transaction_id])
    |> cast_embed(:changes, with: &changes_changeset/2)
    |> cast_embed(:state, with: &state_changeset/2)
  end

  defp changes_changeset(struct, params) do
    struct
    |> cast(params, [])
    |> cast_embed(:orders_created)
    |> cast_embed(:orders_cancelled)
    |> cast_embed(:orders_filled)
    |> cast_embed(:orders_triggered)
    |> cast_embed(:trades_opened)
    |> cast_embed(:trades_reduced)
    |> cast_embed(:trades_closed)
    |> cast_embed(:positions)
    |> cast_embed(:transactions)
  end

  defp state_changeset(struct, params) do
    struct
    |> cast(params, [
      :unrealized_pl, :nav, :margin_used, :margin_available, :position_value,
      :margin_closeout_unrealized_pl, :margin_closeout_nav, :margin_closeout_margin_used,
      :margin_closeout_percent, :margin_closeout_position_value, :withdrawal_limit,
      :margin_call_margin_used, :margin_call_percent, :balance, :pl, :resettable_pl,
      :financing, :commission, :dividend_adjustment, :guaranteed_execution_fees,
      :margin_call_enter_time, :margin_call_extension_count, :last_margin_call_extension_time,
      :last_transaction_id
    ])
    |> cast_embed(:orders, with: &order_state_changeset/2)
    |> cast_embed(:trades, with: &trade_state_changeset/2)
    |> cast_embed(:positions, with: &position_state_changeset/2)
  end

  defp order_state_changeset(struct, params) do
    struct
    |> cast(params, [:id, :trailing_stop_value, :trigger_distance, :is_trigger_distance_exact])
  end

  defp trade_state_changeset(struct, params) do
    struct
    |> cast(params, [:id, :unrealized_pl, :margin_used])
  end

  defp position_state_changeset(struct, params) do
    struct
    |> cast(params, [:instrument, :net_unrealized_pl, :long_unrealized_pl, :short_unrealized_pl, :margin_used])
  end
end
