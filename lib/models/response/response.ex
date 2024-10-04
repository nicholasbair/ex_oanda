defmodule ExOanda.Response do
  @moduledoc """
  Common response schema for Oanda API.
  """

  use TypedEctoSchema
  import Ecto.Changeset

  alias ExOanda.{
    Type.Atom,
    Type.MapOrList
  }

  @primary_key false

  typed_embedded_schema do
    field(:data, MapOrList)
    field(:request_id, :string)
    field(:status, Atom)
  end

  @doc false
  def changeset(struct, params) do
    struct
    |> cast(params, [:data, :request_id, :status])
    |> validate_required([:data, :request_id, :status])
  end
end
