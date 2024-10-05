defmodule ExOanda.TakeProfitDetails do
  @moduledoc """
  Schema for Oanda take profit details.
  """

  use TypedEctoSchema
  import Ecto.Changeset
  alias ExOanda.ClientExtensions

  @primary_key false

  typed_embedded_schema do
    field(:price, :float)
    field(:time_in_force, Ecto.Enum, values: ~w(GTC GTD GFD FOK IOC)a)
    field(:gtd_time, :utc_datetime_usec)
    embeds_one :client_extensions, ClientExtensions
  end

  @doc false
  def changeset(struct, params) do
    struct
    |> cast(params, [:price, :time_in_force, :gtd_time])
    |> cast_embed(:client_extensions)
  end
end
