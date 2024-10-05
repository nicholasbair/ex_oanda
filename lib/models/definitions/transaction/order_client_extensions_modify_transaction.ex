defmodule ExOanda.OrderClientExtensionsModifyTransaction do
  @moduledoc """
  Schema for Oanda order client extensions modify transaction.
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
    field(:type, Atom, default: :ORDER_CLIENT_EXTENSIONS_MODIFY)
    field(:order_id, :string)
    field(:client_order_id, :string)

    embeds_one :trade_client_extensions_modify, ClientExtensions
    embeds_one :order_client_extensions_modify, ClientExtensions
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
      :order_id,
      :client_order_id,
      :trade_client_extensions_modify,
      :order_client_extensions_modify
    ])
    |> cast_embed(:trade_client_extensions_modify)
    |> cast_embed(:order_client_extensions_modify)
  end
end
