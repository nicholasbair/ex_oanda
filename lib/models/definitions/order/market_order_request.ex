defmodule ExOanda.MarketOrderRequest do
  @moduledoc """
  Schema for Oanda market order request.

  [Oanda Docs](https://developer.oanda.com/rest-live-v20/order-df/#MarketOrderRequest)
  """

  use TypedEctoSchema
  import Ecto.Changeset

  alias ExOanda.{
    ClientExtensions,
    GuaranteedStopLossDetails,
    StopLossDetails,
    TakeProfitDetails,
    TrailingStopLossDetails,
    Type.Atom
  }

  @primary_key false

  typed_embedded_schema do
    field(:type, Ecto.Enum, values: [:MARKET], default: :MARKET)
    field(:instrument, Atom)
    field(:units, :integer)
    field(:time_in_force, Ecto.Enum, values: ~w(FOK IOC)a, default: :FOK)
    field(:price_bound, :float)
    field(:position_fill, Ecto.Enum, values: ~w(DEFAULT REDUCE_ONLY)a, default: :DEFAULT)

    embeds_one :client_extensions, ClientExtensions
    embeds_one :take_profit_on_fill, TakeProfitDetails
    embeds_one :stop_loss_on_fill, StopLossDetails
    embeds_one :guaranteed_stop_loss_on_fill, GuaranteedStopLossDetails
    embeds_one :trailing_stop_loss_on_fill, TrailingStopLossDetails
    embeds_one :trade_client_extensions, ClientExtensions
  end

  @doc false
  def changeset(struct, params) do
    struct
    |> cast(params, [
      :type,
      :instrument,
      :units,
      :time_in_force,
      :price_bound,
      :position_fill
    ])
    |> validate_inclusion(:time_in_force, ~w(FOK IOC)a)
    |> validate_inclusion(:position_fill, ~w(DEFAULT REDUCE_ONLY)a)
    |> validate_required([:instrument, :units])
    |> cast_embed(:client_extensions)
    |> cast_embed(:take_profit_on_fill)
    |> cast_embed(:stop_loss_on_fill)
    |> cast_embed(:guaranteed_stop_loss_on_fill)
    |> cast_embed(:trailing_stop_loss_on_fill)
    |> cast_embed(:trade_client_extensions)
  end
end
