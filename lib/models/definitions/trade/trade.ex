defmodule ExOanda.Trade do
  @moduledoc """
  Schema for Oanda trade.
  """

  use TypedEctoSchema
  import Ecto.Changeset
  alias ExOanda.{
    ClientExtensions,
    TradeOrder
  }

  @primary_key false

  typed_embedded_schema do
    field(:id, :string)
    field(:instrument, :string)
    field(:price, :float)
    field(:open_time, :utc_datetime_usec)
    field(:initial_units, :integer)
    field(:initial_margin_required, :float)
    field(:state, Ecto.Enum, values: ~w(OPEN CLOSED CLOSE_WHEN_TRADEABLE)a)
    field(:current_units, :integer)
    field(:realized_pl, :float)
    field(:unrealized_pl, :float)
    field(:margin_used, :float)
    field(:average_close_price, :float)
    field(:closing_transaction_ids, {:array, :string}, default: [])
    field(:financing, :float)
    field(:dividend_adjustment, :float)
    field(:close_time, :utc_datetime_usec)

    embeds_one :take_profit_order, TradeOrder
    embeds_one :stop_loss_order, TradeOrder
    embeds_one :trailing_stop_loss_order, TradeOrder

    embeds_many :client_extensions, ClientExtensions
  end

  @doc false
  def changeset(struct, params) do
    struct
    |> cast(params, [
      :id, :instrument, :price, :open_time, :initial_units,
      :initial_margin_required, :state, :current_units, :realized_pl,
      :unrealized_pl, :margin_used, :average_close_price, :closing_transaction_ids,
      :financing, :dividend_adjustment, :close_time
    ])
    |> cast_embed(:take_profit_order)
    |> cast_embed(:stop_loss_order)
    |> cast_embed(:trailing_stop_loss_order)
    |> cast_embed(:client_extensions)
    |> validate_required([
      :id, :instrument, :price, :open_time, :initial_units,
      :initial_margin_required, :state, :current_units, :realized_pl,
      :unrealized_pl, :margin_used, :average_close_price, :closing_transaction_ids,
      :financing, :dividend_adjustment, :close_time
    ])
  end
end
