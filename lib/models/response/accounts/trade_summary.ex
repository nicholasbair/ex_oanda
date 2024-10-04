defmodule ExOanda.TradeSummary do
  @moduledoc """
  Schema and type definitions for trade summary.
  """

  use TypedEctoSchema
  import Ecto.Changeset

  @primary_key false

  typed_embedded_schema do
    field(:id, :string)
    field(:instrument, :string)
    field(:price, :float)
    field(:open_time, :utc_datetime_usec)
    field(:state, Ecto.Enum, values: [:OPEN, :CLOSED, :CLOSE_WHEN_TRADEABLE])
    field(:initial_units, :integer)
    field(:initial_margin_required, :float)
    field(:current_units, :integer)
    field(:realized_pl, :float)
    field(:unrealized_pl, :float)
    field(:margin_used, :float)
    field(:average_close_price, :float)
    field(:closing_transaction_ids, {:array, :string})
    field(:financing, :float)
    field(:dividend_adjustment, :float)
    field(:close_time, :utc_datetime_usec)
    field(:take_profit_order_id, :string)
    field(:stop_loss_order_id, :string)
    field(:guaranteed_stop_loss_order_id, :string)
    field(:trailing_stop_loss_order_id, :string)

    embeds_many :client_extensions, ClientExtensions, primary_key: false do
      field(:id, :string)
      field(:tag, :string)
      field(:comment, :string)
    end
  end

  @doc false
  def changeset(struct, params) do
    struct
    |> cast(params, [
      :id, :instrument, :price, :open_time, :state, :initial_units,
      :initial_margin_required, :current_units, :realized_pl, :unrealized_pl,
      :margin_used, :average_close_price, :closing_transaction_ids, :financing,
      :dividend_adjustment, :close_time, :take_profit_order_id, :stop_loss_order_id,
      :guaranteed_stop_loss_order_id, :trailing_stop_loss_order_id
    ])
    |> cast_embed(:client_extensions, with: &client_extensions_changeset/2)
    |> validate_required([
      :id, :instrument, :price, :open_time, :state, :initial_units,
      :initial_margin_required, :current_units, :realized_pl, :unrealized_pl,
      :margin_used, :average_close_price, :closing_transaction_ids, :financing,
      :dividend_adjustment, :close_time, :take_profit_order_id, :stop_loss_order_id,
      :guaranteed_stop_loss_order_id, :trailing_stop_loss_order_id
    ])
  end

  defp client_extensions_changeset(struct, params) do
    struct
    |> cast(params, [:id, :tag, :comment])
    |> validate_required([:id])
  end
end
