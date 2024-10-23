defmodule ExOanda.StopLossOrderTransaction do
  @moduledoc """
  Schema for Oanda stop loss order transaction.
  """

  use TypedEctoSchema
  import Ecto.Changeset
  alias ExOanda.{
    Type.Atom,
    ClientExtensions
  }

  @primary_key false

  typed_embedded_schema do
    field(:id, :string)
    field(:time, :utc_datetime_usec)
    field(:user_id, :integer)
    field(:account_id, :string)
    field(:batch_id, :string)
    field(:request_id, :string)
    field(:type, Atom, default: :STOP_LOSS_ORDER)
    field(:trade_id, :string)
    field(:client_trade_id, :string)
    field(:price, :float)
    field(:distance, :float)
    field(:time_in_force, Ecto.Enum, values: ~w(GTC GTD GFD FOK IOC)a)
    field(:gtd_time, :utc_datetime_usec)
    field(:trigger_condition, Ecto.Enum, values: ~w(DEFAULT INVERSE BID ASK MID)a)
    field(:reason, Ecto.Enum, values: ~w(CLIENT_ORDER REPLACEMENT ON_FILL)a)
    field(:order_fill_transaction_id, :string)
    field(:replaces_order_id, :string)
    field(:cancelling_transaction_id, :string)

    embeds_one :client_extensions, ClientExtensions
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
      :trade_id,
      :client_trade_id,
      :price,
      :distance,
      :time_in_force,
      :gtd_time,
      :trigger_condition,
      :reason,
      :order_fill_transaction_id,
      :replaces_order_id,
      :cancelling_transaction_id
    ])
    |> cast_embed(:client_extensions)
  end
end
