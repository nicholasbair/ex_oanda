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
    field(:error_code, :string)
    field(:error_message, :string)
  end

  @doc false
  def changeset(struct, params) do
    struct
    |> cast(params, [:data, :request_id, :status, :error_code, :error_message])
    |> validate_required([:data, :request_id, :status])
  end
end
