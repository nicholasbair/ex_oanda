defmodule ExOanda.FixedPriceOrderTransaction do
  @moduledoc """
  A FixedPriceOrderTransaction represents the creation of a Fixed Price Order in the user's Account.
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
    field(:type, Atom, default: :FIXED_PRICE_ORDER)
    field(:instrument, Atom)
    field(:units, :float)
    field(:price, :float)
    field(:position_fill, :string)
    field(:trade_state, :string)
    field(:reason, :string)
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
      :units,
      :price,
      :position_fill,
      :trade_state,
      :reason
    ])
    |> validate_required([
      :id,
      :time,
      :user_id,
      :account_id,
      :batch_id,
      :type,
      :instrument,
      :units,
      :price
    ])
  end
end
