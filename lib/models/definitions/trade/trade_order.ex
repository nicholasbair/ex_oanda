defmodule ExOanda.TradeOrder do
  @moduledoc """
  Schema for Oanda trade order response.
  """

  use TypedEctoSchema
  import Ecto.Changeset
  alias ExOanda.ClientExtensions

  @primary_key false

  typed_embedded_schema do
    field(:id, :string)
    field(:create_time, :utc_datetime_usec)
    field(:state, Ecto.Enum, values: ~w(PENDING FILLED TRIGGERED CANCELLED)a)
    field(:type, Ecto.Enum, values: ~w(LIMIT STOP MARKET_IF_TOUCHED TAKE_PROFIT)a)
    field(:trade_id, :string)
    field(:client_trade_id, :string)
    field(:price, :float)
    field(:time_in_force, Ecto.Enum, values: ~w(GTC GTD GFD FOK IOC)a, default: :GTC)
    field(:gtd_time, :utc_datetime_usec)
    field(:trigger_condition, Ecto.Enum, values: ~w(DEFAULT INVERSE BID ASK MID)a, default: :DEFAULT)
    field(:filling_transaction_id, :string)
    field(:filled_time, :utc_datetime_usec)
    field(:trade_opened_id, :string)
    field(:trade_reduced_id, :string)
    field(:trade_closed_ids, {:array, :string}, default: [])
    field(:cancelling_transaction_id, :string)
    field(:cancelled_time, :utc_datetime_usec)
    field(:replaces_order_id, :string)
    field(:replaced_by_order_id, :string)

    embeds_one :client_extensions, ClientExtensions
  end

  @doc false
  def changeset(struct, params) do
    struct
    |> cast(params, [
      :id, :create_time, :state, :type, :trade_id, :client_trade_id, :price,
      :time_in_force, :gtd_time, :trigger_condition, :filling_transaction_id,
      :filled_time, :trade_opened_id, :trade_reduced_id, :trade_closed_ids,
      :cancelling_transaction_id, :cancelled_time, :replaces_order_id,
      :replaced_by_order_id
    ])
    |> cast_embed(:client_extensions)
    |> validate_required([
      :id, :create_time, :state, :type, :trade_id, :client_trade_id, :price,
      :time_in_force, :gtd_time, :trigger_condition, :filling_transaction_id,
      :filled_time, :trade_opened_id, :trade_reduced_id, :trade_closed_ids,
      :cancelling_transaction_id, :cancelled_time, :replaces_order_id,
      :replaced_by_order_id
    ])
  end
end
