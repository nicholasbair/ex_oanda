defmodule ExOanda.Response.ListTransactions do
  @moduledoc """
  Schema for Oanda list transactions response.
  """

  use TypedEctoSchema
  import Ecto.Changeset

  @primary_key false

  typed_embedded_schema do
    field(:from, :utc_datetime_usec)
    field(:to, :utc_datetime_usec)
    field(:page_size, :integer)
    field(:type, {:array, :string})
    field(:count, :integer)
    field(:pages, {:array, :string})
    field(:last_transaction_id, :string)
  end

  @doc false
  def changeset(struct, params) do
    struct
    |> cast(params, [:from, :to, :page_size, :type, :count, :pages, :last_transaction_id])
    |> validate_required([:from, :to, :page_size, :type, :count, :pages, :last_transaction_id])
  end
end
