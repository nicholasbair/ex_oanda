defmodule ExOanda.Request.CreateOrderTest do
  use ExUnit.Case, async: true
  alias ExOanda.Request.CreateOrder

  describe "changeset/2" do
    test "valid changeset with order request" do
      params = %{
        order: %{
          type: :MARKET,
          instrument: "EUR_USD",
          units: 1000
        }
      }

      changeset = CreateOrder.changeset(%CreateOrder{}, params)

      assert changeset.valid?
      assert changeset.errors == []
    end

    test "valid changeset with complex order request" do
      params = %{
        order: %{
          type: :LIMIT,
          instrument: "EUR_USD",
          units: 1000,
          price: 1.1000,
          time_in_force: :GTC,
          price_bound: 1.1050,
          trade_id: "trade-123",
          client_trade_id: "client-trade-123",
          position_fill: :DEFAULT,
          distance: 0.0010,
          gtd_time: ~U[2023-12-31 23:59:59.000000Z],
          trigger_condition: :DEFAULT,
          client_extensions: %{
            id: "client-id",
            comment: "Test order"
          },
          take_profit_on_fill: %{
            price: "1.1200",
            time_in_force: :GTC
          },
          stop_loss_on_fill: %{
            price: "1.0800",
            time_in_force: :GTC
          }
        }
      }

      changeset = CreateOrder.changeset(%CreateOrder{}, params)

      assert changeset.valid?
      assert changeset.errors == []
    end

    test "changeset with empty params" do
      params = %{}

      changeset = CreateOrder.changeset(%CreateOrder{}, params)

      refute changeset.valid?
      assert length(changeset.errors) > 0
    end

    test "changeset with invalid order data" do
      params = %{
        order: %{
          type: :INVALID_TYPE,
          instrument: "EUR_USD",
          units: 1000
        }
      }

      changeset = CreateOrder.changeset(%CreateOrder{}, params)

      refute changeset.valid?
      refute changeset.changes.order.valid?
      assert length(changeset.changes.order.errors) > 0
    end
  end
end
