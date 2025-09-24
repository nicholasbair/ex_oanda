defmodule ExOanda.CloseTransaction do
  @moduledoc """
  Schema for Oanda market order transaction.

  [Oanda Docs](https://developer.oanda.com/rest-live-v20/transaction-df/)
  """

  use TypedEctoSchema
  import Ecto.Changeset
  alias ExOanda.Type.Atom

  @primary_key false

  typed_embedded_schema do
    field(:id, :string)
    field(:time, :utc_datetime_usec)
    field(:user_id, :integer)
    field(:account_id, :string)
    field(:batch_id, :string)
    field(:request_id, :string)
    field(:type, Atom, default: :CLOSE)
  end

  @doc false
  def changeset(struct, params) do
    struct
    |> cast(params, [:id, :time, :user_id, :account_id, :batch_id, :request_id, :type])
  end
end
