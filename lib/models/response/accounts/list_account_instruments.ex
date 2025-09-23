defmodule ExOanda.Response.AccountInstruments do
  @moduledoc """
  Schema for Oanda list account instruments response.

  [Oanda Docs](https://developer.oanda.com/rest-live-v20/account-ep/)
  """

  use TypedEctoSchema
  import Ecto.Changeset
  alias ExOanda.Instrument

  @primary_key false

  typed_embedded_schema do
    embeds_many :instruments, Instrument
    field(:last_transaction_id, :string)
  end

  @doc false
  def changeset(struct, params) do
    struct
    |> cast(params, [:last_transaction_id])
    |> cast_embed(:instruments)
  end
end
