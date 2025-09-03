defmodule ExOanda.DividendAdjustmentTransaction do
  @moduledoc """
  A DividendAdjustmentTransaction represents a dividend adjustment made to an Account.
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
    field(:type, Atom, default: :DIVIDEND_ADJUSTMENT)
    field(:instrument, Atom)
    field(:dividend_rate, :float)
    field(:quote_units, :float)
    field(:home_conversion_factors, :map)
    field(:account_balance, :float)
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
      :instrument,
      :dividend_rate,
      :quote_units,
      :home_conversion_factors,
      :account_balance
    ])
    |> validate_required([
      :id,
      :time,
      :user_id,
      :account_id,
      :batch_id,
      :type,
      :instrument
    ])
  end
end
