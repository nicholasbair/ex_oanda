defmodule ExOanda.Error do
  @moduledoc """
  Standard error wrapper
  """

  use TypedEctoSchema
  import Ecto.Changeset

  @primary_key false

  typed_embedded_schema do
    field(:error_code, :string)
    field(:error_message, :string)
  end

  @doc false
  def changeset(struct, params) do
    struct
    |> cast(params, [:error_code, :error_message])
  end
end
