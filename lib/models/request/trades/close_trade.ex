defmodule ExOanda.Request.CloseTrade do
  @moduledoc """
  Schema for Oanda close trade request.
  """

  use TypedEctoSchema
  import Ecto.Changeset
  alias ExOanda.CloseoutUnits

  @primary_key false

  typed_embedded_schema do
    field(:units, CloseoutUnits, default: "ALL")
  end

  @doc false
  def changeset(struct, params) do
    struct
    |> cast(params, [:units])
  end
end
