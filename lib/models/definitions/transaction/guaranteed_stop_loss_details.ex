defmodule ExOanda.GuaranteedStopLossDetails do
  @moduledoc """
  Schema for Oanda guaranteed stop loss details.

  [Oanda Docs](https://developer.oanda.com/rest-live-v20/transaction-df/)
  """

  use TypedEctoSchema
  import Ecto.Changeset
  alias ExOanda.ClientExtensions

  @primary_key false

  typed_embedded_schema do
    field(:price, :float)
    field(:distance, :float)
    field(:time_in_force, Ecto.Enum, values: ~w(GTC GTD GFD FOK IOC)a, default: :GTC)
    field(:gtd_time, :utc_datetime_usec)

    embeds_one :client_extensions, ClientExtensions
  end

  @doc false
  def changeset(struct, params) do
    struct
    |> cast(params, [:price, :distance, :time_in_force, :gtd_time])
    |> cast_embed(:client_extensions)
  end
end
