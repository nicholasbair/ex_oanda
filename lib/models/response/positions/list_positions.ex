defmodule ExOanda.ListPositions do
  @moduledoc """
  Schema for Oanda list positions response.
  """

  use TypedEctoSchema
  import Ecto.Changeset
  alias ExOanda.Position

  @primary_key false

  typed_embedded_schema do
    embeds_many :positions, Position
    field(:last_transaction_id, :string)
  end

  @doc false
  def changeset(struct, params) do
    struct
    |> cast(params, [:last_transaction_id])
    |> cast_embed(:positions)
    |> validate_required([:last_transaction_id])
  end
end
