defmodule ExOanda.TradeClientExtensionsModifyRejectTransaction do
  @moduledoc """
  Schema for Oanda trade client extension modify reject transaction.
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
    field(:type, Atom, default: :TRADE_CLIENT_EXTENSIONS_MODIFY_REJECT)
    field(:trade_id, :string)
    field(:client_trade_id, :string)
    field(:reject_reason, Atom)

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
      :client_trade_id,
      :reject_reason
    ])
    |> cast_embed(:trade_client_extensions_modify)
  end
end
