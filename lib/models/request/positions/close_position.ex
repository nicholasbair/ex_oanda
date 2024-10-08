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
    field(:long_units, CloseoutUnits, default: "ALL")
    field(:short_units, CloseoutUnits, default: "ALL")

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
  end
end
