defmodule ExOanda.DailyFinancing do
  @moduledoc """
  Schema for Oanda daily financing.
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
    field(:type, Atom, default: :DAILY_FINANCING)
    field(:financing, :integer)
    field(:account_balance, :float)
    field(:position_financings, {:array, :map})
  end

  @doc false
  def changeset(struct, params) do
    struct
    |> cast(params, [
      :id,
      :time,
      :user_id,
      :account_id,
      :batch_id,
      :request_id,
      :type,
      :financing,
      :account_balance,
      :position_financings
    ])
  end
end
