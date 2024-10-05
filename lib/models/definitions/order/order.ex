defmodule ExOanda.Order do
  @moduledoc """
  Schema for Oanda order.
  """

  use TypedEctoSchema
  import Ecto.Changeset
  alias ExOanda.ClientExtension

  @primary_key false

  typed_embedded_schema do
    field(:id, :string)
    field(:creat_time, :utc_datetime_usec)
    field(:state, Ecto.Enum, values: [:PENDING, :FILLED, :TRIGGERED, :CANCELLED])

    embeds_many :client_extensions, ClientExtension
  end

  @doc false
  def changeset(struct, params) do
    struct
    |> cast(params, [:id, :creat_time, :state])
    |> cast_embed(:client_extensions)
    |> validate_required([:id, :creat_time, :state])
  end
end
