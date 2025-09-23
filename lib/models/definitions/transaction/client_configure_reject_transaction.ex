defmodule ExOanda.ClientConfigureRejectTransaction do
  @moduledoc """
  Schema for Oanda client configure reject transaction.

  [Oanda Docs](https://developer.oanda.com/rest-live-v20/transaction-df/)
  """

  use TypedEctoSchema
  import Ecto.Changeset
  alias ExOanda.Type.Atom

  @primary_key false

  typed_embedded_schema do
    field(:id, :string)
    field(:time, :string)
    field(:user_id, :integer)
    field(:account_id, :string)
    field(:batch_id, :integer)
    field(:request_id, :integer)
    field(:type, Atom, default: :CLIENT_CONFIGURE_REJECT)
    field(:alias, :string)
    field(:marginRate, :float)
    field(:reject_reason, :string)
  end

  @doc false
  def changeset(struct, params) do
    struct
    |> cast(params, [:id, :time, :user_id, :account_id, :batch_id, :request_id, :type, :alias, :marginRate, :reject_reason])
    |> validate_required([:id, :time, :user_id, :account_id, :batch_id, :request_id, :type, :alias, :marginRate, :reject_reason])
  end
end
