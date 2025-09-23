defmodule ExOanda.Response.FindTrade do
  @moduledoc """
  Schema for Oanda find trade response.

  [Oanda Docs](https://developer.oanda.com/rest-live-v20/trade-ep/)
  """

  use TypedEctoSchema
  import Ecto.Changeset
  alias ExOanda.Trade

  @primary_key false

  typed_embedded_schema do
    embeds_one :trade, Trade
    field(:last_transaction_id, :string)
  end

  @doc false
  def changeset(struct, params) do
    struct
    |> cast(params, [:last_transaction_id])
    |> cast_embed(:trade)
    |> validate_required([:last_transaction_id])
  end
end
