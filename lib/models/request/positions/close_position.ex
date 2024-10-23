defmodule ExOanda.Request.ClosePosition do
  @moduledoc """
  Schema for Oanda close position request.
  """

  use TypedEctoSchema
  import Ecto.Changeset
  alias ExOanda.{
    ClientExtensions,
    CloseoutUnits
  }

  @primary_key false

  typed_embedded_schema do
    field(:long_units, CloseoutUnits)
    field(:short_units, CloseoutUnits)

    embeds_one :long_client_extensions, ClientExtensions
    embeds_one :short_client_extensions, ClientExtensions
  end

  @doc false
  def changeset(struct, params) do
    struct
    |> cast(params, [
      :long_units,
      :short_units,
    ])
    |> cast_embed(:long_client_extensions)
    |> cast_embed(:short_client_extensions)
    |> validate_required_one_of([:long_units, :short_units])
  end

  defp validate_required_one_of(changeset, fields) do
    case Enum.any?(fields, fn field -> get_field(changeset, field) != nil end) do
      true -> changeset
      false -> add_error(changeset, hd(fields), "at least one of #{inspect(fields)} must be present")
    end
  end
end
