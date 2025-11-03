defmodule ExOanda.TakeProfitOrderRequestTest do
  use ExUnit.Case, async: true
  alias ExOanda.TakeProfitOrderRequest

  describe "changeset/2" do
    test "valid changeset with required fields" do
      params = %{
        type: :TAKE_PROFIT,
        trade_id: "trade-123",
        price: 1.1200
      }

      changeset = TakeProfitOrderRequest.changeset(%TakeProfitOrderRequest{}, params)

      assert changeset.valid?
      assert changeset.errors == []
      assert changeset.data.time_in_force == :GTC
    end

    test "valid changeset with all fields" do
      params = %{
        type: :TAKE_PROFIT,
        trade_id: "trade-123",
        client_trade_id: "client-trade-123",
        price: 1.1200,
        time_in_force: :GTD,
        gtd_time: ~U[2023-12-31 23:59:59.000000Z],
        trigger_condition: :DEFAULT,
        client_extensions: %{
          id: "client-id",
          comment: "Test order"
        }
      }

      changeset = TakeProfitOrderRequest.changeset(%TakeProfitOrderRequest{}, params)

      assert changeset.valid?
      assert changeset.errors == []
    end

    test "requires price and trade_id" do
      params = %{
        type: :TAKE_PROFIT,
        price: 1.1200
      }

      changeset = TakeProfitOrderRequest.changeset(%TakeProfitOrderRequest{}, params)

      refute changeset.valid?
      assert length(changeset.errors) > 0
    end

    test "default time_in_force is GTC" do
      params = %{
        type: :TAKE_PROFIT,
        trade_id: "trade-123",
        price: 1.1200
      }

      changeset = TakeProfitOrderRequest.changeset(%TakeProfitOrderRequest{}, params)

      assert changeset.valid?
      assert changeset.data.time_in_force == :GTC
    end
  end
end
