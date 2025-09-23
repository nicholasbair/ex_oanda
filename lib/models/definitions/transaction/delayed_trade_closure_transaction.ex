defmodule ExOanda.DelayedTradeClosureTransaction do
  @moduledoc """
  A DelayedTradeClosureTransaction represents the immediate closure of a Trade that was
  requested to be delayed.

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
    field(:type, Atom, default: :DELAYED_TRADE_CLOSURE)
    field(:reason, :string)
    field(:trade_ids, {:array, :string})
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
      :reason,
      :trade_ids
    ])
    |> validate_required([
      :id,
      :time,
      :user_id,
      :account_id,
      :batch_id,
      :type
    ])
  end
end
