defmodule ExOanda.Response.TransactionHeartbeat do
  @moduledoc """
  Schema for Oanda transaction heartbeat response.
  """

  use TypedEctoSchema
  import Ecto.Changeset
  alias ExOanda.Type.Atom

  @primary_key false

  typed_embedded_schema do
    field(:last_transaction_id, :string)
    field(:time, :utc_datetime_usec)
    field(:type, Atom, default: :HEARTBEAT)
  end

  @doc false
  def changeset(struct, params) do
    struct
    |> cast(params, [:last_transaction_id, :time, :type])
  end
end
