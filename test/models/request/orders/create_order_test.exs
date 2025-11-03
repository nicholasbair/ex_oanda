defmodule ExOanda.Request.CreateOrderTest do
  use ExUnit.Case, async: true
  alias ExOanda.Request.CreateOrder

  describe "changeset/2" do
    test "valid changeset with market order" do
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

      order = Ecto.Changeset.apply_changes(changeset).order
      assert order.type == :MARKET
      assert order.time_in_force == :FOK
    end

    test "valid changeset with limit order" do
      params = %{
        order: %{
          type: :LIMIT,
          instrument: "EUR_USD",
          units: 1000,
          price: 1.1000,
          time_in_force: :GTC
        }
      }

      changeset = CreateOrder.changeset(%CreateOrder{}, params)

      assert changeset.valid?
      assert changeset.errors == []

      order = Ecto.Changeset.apply_changes(changeset).order
      assert order.type == :LIMIT
      assert order.time_in_force == :GTC
    end

    test "valid changeset with stop order" do
      params = %{
        order: %{
          type: :STOP,
          instrument: "EUR_USD",
          units: 1000,
          price: 1.1000,
          time_in_force: :GTC
        }
      }

      changeset = CreateOrder.changeset(%CreateOrder{}, params)

      assert changeset.valid?
      assert changeset.errors == []

      order = Ecto.Changeset.apply_changes(changeset).order
      assert order.type == :STOP
    end

    test "valid changeset with market if touched order" do
      params = %{
        order: %{
          type: :MARKET_IF_TOUCHED,
          instrument: "EUR_USD",
          units: 1000,
          price: 1.1000,
          time_in_force: :GTC
        }
      }

      changeset = CreateOrder.changeset(%CreateOrder{}, params)

      assert changeset.valid?
      assert changeset.errors == []

      order = Ecto.Changeset.apply_changes(changeset).order
      assert order.type == :MARKET_IF_TOUCHED
    end

    test "valid changeset with take profit order" do
      params = %{
        order: %{
          type: :TAKE_PROFIT,
          trade_id: "trade-123",
          price: 1.1200,
          time_in_force: :GTC
        }
      }

      changeset = CreateOrder.changeset(%CreateOrder{}, params)

      assert changeset.valid?
      assert changeset.errors == []

      order = Ecto.Changeset.apply_changes(changeset).order
      assert order.type == :TAKE_PROFIT
    end

    test "valid changeset with stop loss order" do
      params = %{
        order: %{
          type: :STOP_LOSS,
          trade_id: "trade-123",
          price: 1.0800,
          time_in_force: :GTC
        }
      }

      changeset = CreateOrder.changeset(%CreateOrder{}, params)

      assert changeset.valid?
      assert changeset.errors == []

      order = Ecto.Changeset.apply_changes(changeset).order
      assert order.type == :STOP_LOSS
    end

    test "valid changeset with guaranteed stop loss order" do
      params = %{
        order: %{
          type: :GUARANTEED_STOP_LOSS,
          trade_id: "trade-123",
          price: 1.0750,
          time_in_force: :GTC
        }
      }

      changeset = CreateOrder.changeset(%CreateOrder{}, params)

      assert changeset.valid?
      assert changeset.errors == []

      order = Ecto.Changeset.apply_changes(changeset).order
      assert order.type == :GUARANTEED_STOP_LOSS
    end

    test "valid changeset with trailing stop loss order" do
      params = %{
        order: %{
          type: :TRAILING_STOP_LOSS,
          trade_id: "trade-123",
          distance: 0.0100,
          time_in_force: :GTC
        }
      }

      changeset = CreateOrder.changeset(%CreateOrder{}, params)

      assert changeset.valid?
      assert changeset.errors == []

      order = Ecto.Changeset.apply_changes(changeset).order
      assert order.type == :TRAILING_STOP_LOSS
    end

    test "changeset with empty params" do
      params = %{}

      changeset = CreateOrder.changeset(%CreateOrder{}, params)

      refute changeset.valid?
      assert length(changeset.errors) > 0
    end

    test "changeset with invalid order type" do
      params = %{
        order: %{
          type: :INVALID_TYPE,
          instrument: "EUR_USD",
          units: 1000
        }
      }

      assert_raise RuntimeError, fn ->
        CreateOrder.changeset(%CreateOrder{}, params)
      end
    end

    test "limit order requires price" do
      params = %{
        order: %{
          type: :LIMIT,
          instrument: "EUR_USD",
          units: 1000
        }
      }

      changeset = CreateOrder.changeset(%CreateOrder{}, params)
      refute changeset.valid?
    end

    test "take profit order requires price and trade_id" do
      params = %{
        order: %{
          type: :TAKE_PROFIT,
          price: 1.1200
        }
      }

      changeset = CreateOrder.changeset(%CreateOrder{}, params)
      refute changeset.valid?

      order_changeset = Ecto.Changeset.get_change(changeset, :order)
      assert length(order_changeset.errors) > 0
    end

    test "trailing stop loss order requires distance and trade_id" do
      params = %{
        order: %{
          type: :TRAILING_STOP_LOSS,
          distance: 0.0100
        }
      }

      changeset = CreateOrder.changeset(%CreateOrder{}, params)
      refute changeset.valid?

      order_changeset = Ecto.Changeset.get_change(changeset, :order)
      assert length(order_changeset.errors) > 0
    end

    test "market order default time_in_force is FOK" do
      params = %{
        order: %{
          type: :MARKET,
          instrument: "EUR_USD",
          units: 1000
        }
      }

      changeset = CreateOrder.changeset(%CreateOrder{}, params)

      assert changeset.valid?

      order = Ecto.Changeset.apply_changes(changeset).order
      assert order.time_in_force == :FOK
    end

    test "limit order default time_in_force is GTC" do
      params = %{
        order: %{
          type: :LIMIT,
          instrument: "EUR_USD",
          units: 1000,
          price: 1.1000
        }
      }

      changeset = CreateOrder.changeset(%CreateOrder{}, params)

      assert changeset.valid?

      order = Ecto.Changeset.apply_changes(changeset).order
      assert order.time_in_force == :GTC
    end
  end
end
