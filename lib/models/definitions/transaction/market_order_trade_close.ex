defmodule ExOanda.MarketOrderTradeClose do
  @moduledoc """
  Schema for Oanda market order trade close.
  """

  use TypedEctoSchema
  import Ecto.Changeset

  @primary_key false

  typed_embedded_schema do
    field(:trade_id, :string)
    field(:client_trade_id, :string)
    field(:units, :float)
  end

  @doc false
  def changeset(struct, params) do
    struct
    |> cast(params, [:trade_id, :client_trade_id, :units])
  end
end
