defmodule ExOanda.CalculatedTradeState do
  @moduledoc """
  Schema for Oanda calculated trade state.

  [Oanda Docs](https://developer.oanda.com/rest-live-v20/trade-df/)
  """

  use TypedEctoSchema
  import Ecto.Changeset

  @primary_key false

  typed_embedded_schema do
    field(:id, :string)
    field(:unrealized_pl, :float)
    field(:margin_used, :float)
  end

  @doc false
  def changeset(struct, params) do
    struct
    |> cast(params, [:id, :unrealized_pl, :margin_used])
    |> validate_required([:id, :unrealized_pl, :margin_used])
  end
end
