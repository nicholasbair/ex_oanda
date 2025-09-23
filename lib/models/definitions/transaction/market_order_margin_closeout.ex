defmodule ExOanda.MarketOrderMarginCloseout do
  @moduledoc """
  Schema for Oanda market order margin closeout.

  [Oanda Docs](https://developer.oanda.com/rest-live-v20/transaction-df/)
  """

  use TypedEctoSchema
  import Ecto.Changeset

  @primary_key false

  typed_embedded_schema do
    field(:reason, Ecto.Enum, values: ~w(MARGIN_CHECK_VIOLATION REGULATORY_MARGIN_CALL_VIOLATION REGULATORY_MARGIN_CHECK_VIOLATION)a)
  end

  @doc false
  def changeset(struct, params) do
    struct
    |> cast(params, [:reason])
  end
end
