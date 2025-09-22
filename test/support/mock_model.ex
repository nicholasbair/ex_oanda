defmodule ExOanda.Test.Support.MockModel do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field(:required_field, :string)
  end

  def changeset(struct, params) do
    struct
    |> cast(params, [:required_field])
    |> validate_required([:required_field])
  end
end
