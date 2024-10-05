defmodule ExOanda.AccountChanges do
  @moduledoc """
  Schema for Oanda account changes.
  """

  use TypedEctoSchema
  import Ecto.Changeset

  alias ExOanda.{
    Order,
    Position,
    TradeSummary,
    Transaction
  }

  @primary_key false

  typed_embedded_schema do
    embeds_many :orders_created, Order
    embeds_many :orders_cancelled, Order
    embeds_many :orders_filled, Order
    embeds_many :orders_triggered, Order

    embeds_many :trades_opened, TradeSummary
    embeds_many :trades_reduced, TradeSummary
    embeds_many :trades_closed, TradeSummary

    embeds_many :positions, Position

    embeds_many :transactions, Transaction
  end

  @doc false
  def changeset(struct, _params) do
    struct
    |> cast_embed(:orders_created)
    |> cast_embed(:orders_cancelled)
    |> cast_embed(:orders_filled)
    |> cast_embed(:orders_triggered)
    |> cast_embed(:trades_opened)
    |> cast_embed(:trades_reduced)
    |> cast_embed(:trades_closed)
    |> cast_embed(:positions)
    |> cast_embed(:transactions)
  end
end
