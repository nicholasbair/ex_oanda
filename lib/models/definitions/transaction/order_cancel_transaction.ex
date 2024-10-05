defmodule ExOanda.OrderCancelTransaction do
  @moduledoc """
  Schema for Oanda order cancel transaction.
  """

  use TypedEctoSchema
  import Ecto.Changeset
  alias ExOanda.Type.Atom

  @primary_key false

  typed_embedded_schema do
    field(:id, :string)
    field(:time, :utc_datetime_usec)
    field(:user_id, :integer)
    field(:account_id, :string)
    field(:batch_id, :string)
    field(:request_id, :string)
    field(:type, Atom, default: :ORDER_CANCEL)
    field(:order_id, :string)
    field(:client_order_id, :string)
    field(:reason, Ecto.Enum, values: [
      # TODO: this list is incomplete for order cancel
      :CLIENT_REQUEST,
      :MIGRATION,
      :REPLACEMENT,
      :FILL,
      :RESET,
      :MARKET_HALTED,
      :LINKED_TRADE_CLOSED,
      :TIME_IN_FORCE_EXPIRED,
      :INSUFFICIENT_MARGIN,
      :STOP_LOSS_ON_FILL_LOSS,
      :STOP_LOSS_ON_FILL_PRICE,
      :TAKE_PROFIT_ON_FILL_PRICE,
      :TRAILING_STOP_LOSS_ON_FILL_PRICE,
      :MARKET_ORDER_MARGIN_CLOSEOUT,
      :MARKET_ORDER_DELAYED_TRADE_CLOSE,
      :MARKET_ORDER_POSITION_CLOSEOUT,
      :MARKET_ORDER_TRADE_CLOSE,
      :MARKET_ORDER
    ])
    field(:replaced_by_order_id, :string)
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
      :order_id,
      :client_order_id,
      :reason,
      :replaced_by_order_id
    ])
    |> validate_required([
      :id,
      :time,
      :user_id,
      :account_id,
      :batch_id,
      :request_id,
      :type,
      :order_id,
      :client_order_id,
      :reason,
      :replaced_by_order_id
    ])
  end
end
