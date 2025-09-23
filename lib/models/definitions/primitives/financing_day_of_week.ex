defmodule ExOanda.FinancingDayOfWeek do
  @moduledoc """
  Schema for Oanda financing day of week.

  [Oanda Docs](https://developer.oanda.com/rest-live-v20/primitives-df/)
  """

  use TypedEctoSchema
  import Ecto.Changeset

  @primary_key false

  typed_embedded_schema do
    field(:day_of_week, Ecto.Enum, values: ~w(SUNDAY MONDAY TUESDAY WEDNESDAY THURSDAY FRIDAY SATURDAY)a)
    field(:days_charged, :integer)
  end

  @doc false
  def changeset(struct, params) do
    struct
    |> cast(params, [:day_of_week, :days_charged])
    |> validate_required([:day_of_week, :days_charged])
  end
end
