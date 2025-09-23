defmodule ExOanda.HomeConversions do
  @moduledoc """
  Schema for Oanda home conversions.

  [Oanda Docs](https://developer.oanda.com/rest-live-v20/pricing-df/)
  """

  use TypedEctoSchema
  import Ecto.Changeset

  @primary_key false

  typed_embedded_schema do
    field(:currency, :string)
    field(:account_gain, :float)
    field(:account_loss, :float)
    field(:position_value, :float)
  end

  @doc false
  def changeset(struct, params) do
    struct
    |> cast(params, [:currency, :account_gain, :account_loss, :position_value])
    |> validate_required([:currency, :account_gain, :account_loss, :position_value])
  end
end
