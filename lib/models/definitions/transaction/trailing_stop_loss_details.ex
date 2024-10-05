defmodule ExOanda.TrailingStopLossDetails do
  @moduledoc """
  Schema for Oanda trailing stop loss details.
  """

  use TypedEctoSchema
  import Ecto.Changeset
  alias ExOanda.ClientExtensions

  @primary_key false

  typed_embedded_schema do
    field(:distance, :float)
    field(:time_in_force, Ecto.Enum, values: ~w(GTC GTD GFD FOK IOC)a)
    field(:gtd_time, :naive_datetime)
    embeds_one :client_extensions, ClientExtensions
  end

  @doc false
  def changeset(struct, params) do
    struct
    |> cast(params, [:distance, :time_in_force, :gtd_time])
    |> cast_embed(:client_extensions)
  end
end
