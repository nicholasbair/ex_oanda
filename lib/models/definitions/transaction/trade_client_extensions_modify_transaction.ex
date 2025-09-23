defmodule ExOanda.TradeClientExtensionsModifyTransaction do
  @moduledoc """
  Schema for Oanda trade client extensions modify transaction.

  [Oanda Docs](https://developer.oanda.com/rest-live-v20/transaction-df/)
  """

  use TypedEctoSchema
  import Ecto.Changeset
  alias ExOanda.{
    ClientExtensions,
    Type.Atom
  }

  @primary_key false

  typed_embedded_schema do
    field(:id, :string)
    field(:time, :utc_datetime_usec)
    field(:user_id, :integer)
    field(:account_id, :string)
    field(:batch_id, :string)
    field(:request_id, :string)
    field(:type, Atom, default: :TRADE_CLIENT_EXTENSIONS_MODIFY)
    field(:trade_id, :string)
    field(:client_trade_id, :string)

    embeds_one :trade_client_extensions_modify, ClientExtensions
  end

  @doc false
  def changeset(struct, params) do
    struct
    |> cast(params, [
      :id,
      :time,
      :user_id,
      :account_id,
      :batch_id,
      :request_id,
      :type,
      :trade_id,
      :client_trade_id
    ])
    |> cast_embed(:trade_client_extensions_modify)
  end
end
