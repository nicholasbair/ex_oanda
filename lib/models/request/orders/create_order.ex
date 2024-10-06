defmodule ExOanda.Request.CreateOrder do
  @moduledoc """
  Schema for Oanda order create request.
  """

  use TypedEctoSchema
  import Ecto.Changeset
  alias ExOanda.OrderRequest

  @primary_key false

  typed_embedded_schema do
    embeds_one :order, OrderRequest
  end

  @doc false
  def changeset(struct, params) do
    struct
    |> cast(params, [])
    |> cast_embed(:order)
  end
end
