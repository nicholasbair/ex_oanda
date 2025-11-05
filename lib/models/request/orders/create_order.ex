defmodule ExOanda.Request.CreateOrder do
  @moduledoc """
  Schema for Oanda order create request.

  [Oanda Docs](https://developer.oanda.com/rest-live-v20/order-ep/)
  """

  use Ecto.Schema
  import Ecto.Changeset
  import PolymorphicEmbed

  alias ExOanda.{
    GuaranteedStopLossOrderRequest,
    LimitOrderRequest,
    MarketIfTouchedOrderRequest,
    MarketOrderRequest,
    StopLossOrderRequest,
    StopOrderRequest,
    TakeProfitOrderRequest,
    TrailingStopLossOrderRequest
  }

  @primary_key false

  @type t :: %__MODULE__{
          order: order_request()
        }

  @type order_request ::
          MarketOrderRequest.t()
          | LimitOrderRequest.t()
          | StopOrderRequest.t()
          | MarketIfTouchedOrderRequest.t()
          | TakeProfitOrderRequest.t()
          | StopLossOrderRequest.t()
          | GuaranteedStopLossOrderRequest.t()
          | TrailingStopLossOrderRequest.t()

  embedded_schema do
    polymorphic_embeds_one(:order,
      types: [
        MARKET: MarketOrderRequest,
        LIMIT: LimitOrderRequest,
        STOP: StopOrderRequest,
        MARKET_IF_TOUCHED: MarketIfTouchedOrderRequest,
        TAKE_PROFIT: TakeProfitOrderRequest,
        STOP_LOSS: StopLossOrderRequest,
        GUARANTEED_STOP_LOSS: GuaranteedStopLossOrderRequest,
        TRAILING_STOP_LOSS: TrailingStopLossOrderRequest
      ],
      type_field_name: :type,
      on_type_not_found: :changeset_error,
      on_replace: :update
    )
  end

  @doc false
  def changeset(struct, params) do
    struct
    |> cast(params, [])
    |> cast_polymorphic_embed(:order)
    |> validate_required([:order])
  end
end
