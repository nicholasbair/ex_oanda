defmodule ExOanda.TransferFundsRejectTransaction do
  @moduledoc """
  A TransferFundsRejectTransaction represents the rejection of the transfer of funds in/out of an Account.

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
    field(:type, Atom, default: :TRANSFER_FUNDS_REJECT)
    field(:amount, :float)
    field(:funding_reason, :string)
    field(:comment, :string)
    field(:reject_reason, :string)
  end

  def changeset(struct, data) do
    struct
    |> cast(data, [
      :id,
      :time,
      :user_id,
      :account_id,
      :batch_id,
      :request_id,
      :type,
      :amount,
      :funding_reason,
      :comment,
      :reject_reason
    ])
    |> validate_required([
      :id,
      :time,
      :user_id,
      :account_id,
      :batch_id,
      :type,
      :reject_reason
    ])
  end
end
