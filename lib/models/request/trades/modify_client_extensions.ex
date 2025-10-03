defmodule ExOanda.Request.TradeModifyClientExtensions do
  @moduledoc """
  Oanda trade modify client extensions request.

  [Oanda Docs](https://developer.oanda.com/rest-live-v20/trade-ep/)
  """

  use TypedEctoSchema
  import Ecto.Changeset

  alias ExOanda.ClientExtensions

  @primary_key false

  typed_embedded_schema do
    embeds_one :client_extensions, ClientExtensions
  end

  @doc false
  def changeset(struct, params) do
    struct
    |> cast(params, [])
    |> cast_embed(:client_extensions)
    |> validate_required([:client_extensions])
  end
end
