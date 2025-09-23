defmodule ExOanda.OrderRejectTransaction do
  @moduledoc """
  An OrderRejectTransaction represents the rejection of an Order creation request.

  [Oanda Docs](https://developer.oanda.com/rest-live-v20/transaction-df/)
  """

  use TypedEctoSchema
  import Ecto.Changeset
  alias ExOanda.Type.Atom

  @primary_key false

  embedded_schema do
    field(:id, :string)
    field(:time, :utc_datetime_usec)
    field(:user_id, :integer)
    field(:account_id, :string)
    field(:batch_id, :string)
    field(:request_id, :string)
    field(:type, Atom, default: :ORDER_REJECT)
    field(:order_id, :string)
    field(:client_order_id, :string)
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
      :order_id,
      :client_order_id,
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
