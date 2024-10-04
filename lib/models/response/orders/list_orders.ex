defmodule ExOanda.ListOrders do
  @moduledoc """
  Schema for Oanda list orders response.
  """

  use TypedEctoSchema
  import Ecto.Changeset
  alias ExOanda.Order

  @primary_key false

  typed_embedded_schema do
    embeds_many :orders, Order
    field(:last_transaction_id, :string)
  end

  @doc false
  def changeset(struct, params) do
    struct
    |> cast(params, [:last_transaction_id])
    |> cast_embed(:orders)
  end
end
