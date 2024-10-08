defmodule ExOanda.Response.PricingHeartbeat do
  @moduledoc """
  Schema for Oanda pricing heartbeat response.
  """

  use TypedEctoSchema
  import Ecto.Changeset
  alias ExOanda.Type.Atom

  @primary_key false

  typed_embedded_schema do
    field(:time, :utc_datetime_usec)
    field(:type, Atom, default: :HEARTBEAT)
  end

  @doc false
  def changeset(struct, params) do
    struct
    |> cast(params, [:time, :type])
  end
end
