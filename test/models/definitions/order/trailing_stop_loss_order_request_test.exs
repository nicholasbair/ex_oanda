defmodule ExOanda.TrailingStopLossOrderRequestTest do
  use ExUnit.Case, async: true
  alias ExOanda.TrailingStopLossOrderRequest

  describe "changeset/2" do
    test "valid changeset with required fields" do
      params = %{
        type: :TRAILING_STOP_LOSS,
        trade_id: "trade-123",
        distance: 0.0100
      }

      changeset = TrailingStopLossOrderRequest.changeset(%TrailingStopLossOrderRequest{}, params)

      assert changeset.valid?
      assert changeset.errors == []
      assert changeset.data.time_in_force == :GTC
    end

    test "valid changeset with all fields" do
      params = %{
        type: :TRAILING_STOP_LOSS,
        trade_id: "trade-123",
        client_trade_id: "client-trade-123",
        distance: 0.0100,
        time_in_force: :GTD,
        gtd_time: ~U[2023-12-31 23:59:59.000000Z],
        trigger_condition: :DEFAULT,
        client_extensions: %{
          id: "client-id",
          comment: "Test order"
        }
      }

      changeset = TrailingStopLossOrderRequest.changeset(%TrailingStopLossOrderRequest{}, params)

      assert changeset.valid?
      assert changeset.errors == []
    end

    test "requires distance and trade_id" do
      params = %{
        type: :TRAILING_STOP_LOSS,
        distance: 0.0100
      }

      changeset = TrailingStopLossOrderRequest.changeset(%TrailingStopLossOrderRequest{}, params)

      refute changeset.valid?
      refute Enum.empty?(changeset.errors)
    end

    test "default time_in_force is GTC" do
      params = %{
        type: :TRAILING_STOP_LOSS,
        trade_id: "trade-123",
        distance: 0.0100
      }

      changeset = TrailingStopLossOrderRequest.changeset(%TrailingStopLossOrderRequest{}, params)

      assert changeset.valid?
      assert changeset.data.time_in_force == :GTC
    end
  end
end
