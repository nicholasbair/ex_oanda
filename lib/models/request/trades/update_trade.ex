defmodule ExOanda.Request.UpdateTrade do
  @moduledoc """
  Schema for Oanda trade update request.

  [Oanda Docs](https://developer.oanda.com/rest-live-v20/trade-ep/)
  """

  use TypedEctoSchema
  import Ecto.Changeset

  @primary_key false

  typed_embedded_schema do
    embeds_one :take_profit, ExOanda.TakeProfitDetails
    embeds_one :stop_loss, ExOanda.StopLossDetails
    embeds_one :trailing_stop_loss, ExOanda.TrailingStopLossDetails
    embeds_one :guaranteed_stop_loss, ExOanda.GuaranteedStopLossDetails
  end

  @doc false
  def changeset(struct, params) do
    struct
    |> cast(params, [])
    |> cast_embed(:take_profit)
    |> cast_embed(:stop_loss)
    |> cast_embed(:trailing_stop_loss)
    |> cast_embed(:guaranteed_stop_loss)
  end
end
