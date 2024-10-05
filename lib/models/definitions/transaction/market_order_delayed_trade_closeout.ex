defmodule ExOanda.MarketOrderDelayedTradeCloseout do
  @moduledoc """
  Schema for Oanda market order delayed trade closeout.
  """

  use TypedEctoSchema
  import Ecto.Changeset

  @primary_key false

  typed_embedded_schema do
    field(:trade_id, :string)
    field(:client_trade_id, :string)
    field(:source_transaction_id, :string)
  end

  @doc false
  def changeset(struct, params) do
    struct
    |> cast(params, [:trade_id, :client_trade_id, :source_transaction_id])
  end
end
