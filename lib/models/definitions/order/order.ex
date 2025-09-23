defmodule ExOanda.Order do
  @moduledoc """
  Schema for Oanda order.

  [Oanda Docs](https://developer.oanda.com/rest-live-v20/order-df/)
  """

  use TypedEctoSchema
  import Ecto.Changeset
  alias ExOanda.ClientExtensions

  @primary_key false

  typed_embedded_schema do
    field(:id, :string)
    field(:create_time, :utc_datetime_usec)
    field(:state, Ecto.Enum, values: ~w(PENDING FILLED TRIGGERED CANCELLED)a)

    embeds_one :client_extensions, ClientExtensions
  end

  @doc false
  def changeset(struct, params) do
    struct
    |> cast(params, [:id, :create_time, :state])
    |> cast_embed(:client_extensions)
    |> validate_required([:id, :create_time, :state])
  end
end
