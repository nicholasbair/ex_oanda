defmodule ExOanda.Response.ListTrades do
  @moduledoc """
  Schema for Oanda list trades response.
  """

  use TypedEctoSchema
  import Ecto.Changeset
  alias ExOanda.Trade

  @primary_key false

  typed_embedded_schema do
    embeds_many :trades, Trade

    field(:last_transaction_id, :string)
  end

  @doc false
  def changeset(struct, params) do
    struct
    |> cast(params, [:last_transaction_id])
    |> cast_embed(:trades)
    |> validate_required([:last_transaction_id])
  end
end
