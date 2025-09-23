defmodule ExOanda.Transaction do
  @moduledoc """
  Schema for Oanda transaction.

  [Oanda Docs](https://developer.oanda.com/rest-live-v20/transaction-df/)
  """

  use TypedEctoSchema
  import Ecto.Changeset

  @primary_key false

  typed_embedded_schema do
    field(:id, :string)
    field(:time, :utc_datetime_usec)
    field(:user_id, :integer)
    field(:account_id, :string)
    field(:batch_id, :string)
    field(:request_id, :string)
  end

  @doc false
  def changeset(struct, params) do
    struct
    |> cast(params, [:id, :time, :user_id, :account_id, :batch_id, :request_id])
    |> validate_required([:id, :time, :user_id, :account_id, :batch_id, :request_id])
  end
end
