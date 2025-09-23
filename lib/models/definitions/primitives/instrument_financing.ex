defmodule ExOanda.InstrumentFinancing do
  @moduledoc """
  Schema for Oanda instrument financing.

  [Oanda Docs](https://developer.oanda.com/rest-live-v20/primitives-df/)
  """

  use TypedEctoSchema
  import Ecto.Changeset
  alias ExOanda.FinancingDayOfWeek

  @primary_key false

  typed_embedded_schema do
    field(:long_rate, :float)
    field(:short_rate, :float)
    embeds_many :financing_days_of_week, FinancingDayOfWeek
  end

  @doc false
  def changeset(struct, params) do
    struct
    |> cast(params, [:long_rate, :short_rate])
    |> cast_embed(:financing_days_of_week)
  end
end
