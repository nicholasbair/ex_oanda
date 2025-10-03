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
    |> validate_required_one_of([:take_profit, :stop_loss, :trailing_stop_loss, :guaranteed_stop_loss])
  end

  defp validate_required_one_of(changeset, fields) do
    case Enum.any?(fields, fn field -> get_field(changeset, field) != nil end) do
      true -> changeset
      false -> add_error(changeset, hd(fields), "at least one of #{inspect(fields)} must be present")
    end
  end
end
