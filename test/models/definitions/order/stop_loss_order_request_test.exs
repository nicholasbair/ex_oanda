defmodule ExOanda.StopLossOrderRequestTest do
  use ExUnit.Case, async: true
  alias ExOanda.StopLossOrderRequest

  describe "changeset/2" do
    test "valid changeset with required fields and price" do
      params = %{
        type: :STOP_LOSS,
        trade_id: "trade-123",
        price: 1.2345
      }

      changeset = StopLossOrderRequest.changeset(%StopLossOrderRequest{}, params)

      assert changeset.valid?
      assert changeset.errors == []
      assert changeset.data.time_in_force == :GTC
      assert changeset.data.trigger_condition == :DEFAULT
    end

    test "valid changeset with required fields and distance" do
      params = %{
        type: :STOP_LOSS,
        trade_id: "trade-123",
        distance: 0.0100
      }

      changeset = StopLossOrderRequest.changeset(%StopLossOrderRequest{}, params)

      assert changeset.valid?
      assert changeset.errors == []
    end

    test "valid changeset with all fields using price" do
      params = %{
        type: :STOP_LOSS,
        trade_id: "trade-123",
        client_trade_id: "client-trade-123",
        price: 1.2345,
        time_in_force: :GTD,
        gtd_time: ~U[2023-12-31 23:59:59.000000Z],
        trigger_condition: :BID,
        client_extensions: %{
          id: "client-id",
          comment: "Test order"
        }
      }

      changeset = StopLossOrderRequest.changeset(%StopLossOrderRequest{}, params)

      assert changeset.valid?
      assert changeset.errors == []
    end

    test "valid changeset with all fields using distance" do
      params = %{
        type: :STOP_LOSS,
        trade_id: "trade-123",
        client_trade_id: "client-trade-123",
        distance: 0.0100,
        time_in_force: :GFD,
        gtd_time: ~U[2023-12-31 23:59:59.000000Z],
        trigger_condition: :ASK,
        client_extensions: %{
          id: "client-id",
          comment: "Test order"
        }
      }

      changeset = StopLossOrderRequest.changeset(%StopLossOrderRequest{}, params)

      assert changeset.valid?
      assert changeset.errors == []
    end

    test "requires trade_id" do
      params = %{
        type: :STOP_LOSS,
        price: 1.2345
      }

      changeset = StopLossOrderRequest.changeset(%StopLossOrderRequest{}, params)

      refute changeset.valid?
      assert {:trade_id, {"can't be blank", [validation: :required]}} in changeset.errors
    end

    test "requires either price or distance" do
      params = %{
        type: :STOP_LOSS,
        trade_id: "trade-123"
      }

      changeset = StopLossOrderRequest.changeset(%StopLossOrderRequest{}, params)

      refute changeset.valid?
      assert {:base, {"either price or distance must be specified", []}} in changeset.errors
    end

    test "rejects both price and distance" do
      params = %{
        type: :STOP_LOSS,
        trade_id: "trade-123",
        price: 1.2345,
        distance: 0.0100
      }

      changeset = StopLossOrderRequest.changeset(%StopLossOrderRequest{}, params)

      refute changeset.valid?
      assert {:base, {"only one of price or distance may be specified", []}} in changeset.errors
    end

    test "validates time_in_force enum values" do
      valid_values = [:GTC, :GTD, :GFD]

      for tif <- valid_values do
        params = %{
          type: :STOP_LOSS,
          trade_id: "trade-123",
          price: 1.2345,
          time_in_force: tif
        }

        changeset = StopLossOrderRequest.changeset(%StopLossOrderRequest{}, params)
        assert changeset.valid?, "Expected #{tif} to be valid"
      end
    end

    test "validates trigger_condition enum values" do
      valid_values = [:DEFAULT, :INVERSE, :BID, :ASK, :MID]

      for trigger <- valid_values do
        params = %{
          type: :STOP_LOSS,
          trade_id: "trade-123",
          price: 1.2345,
          trigger_condition: trigger
        }

        changeset = StopLossOrderRequest.changeset(%StopLossOrderRequest{}, params)
        assert changeset.valid?, "Expected #{trigger} to be valid"
      end
    end

    test "default time_in_force is GTC" do
      params = %{
        type: :STOP_LOSS,
        trade_id: "trade-123",
        price: 1.2345
      }

      changeset = StopLossOrderRequest.changeset(%StopLossOrderRequest{}, params)

      assert changeset.valid?
      assert changeset.data.time_in_force == :GTC
    end

    test "default trigger_condition is DEFAULT" do
      params = %{
        type: :STOP_LOSS,
        trade_id: "trade-123",
        price: 1.2345
      }

      changeset = StopLossOrderRequest.changeset(%StopLossOrderRequest{}, params)

      assert changeset.valid?
      assert changeset.data.trigger_condition == :DEFAULT
    end

    test "handles client_extensions embedding" do
      params = %{
        type: :STOP_LOSS,
        trade_id: "trade-123",
        price: 1.2345,
        client_extensions: %{
          id: "test-id",
          tag: "test-tag",
          comment: "test comment"
        }
      }

      changeset = StopLossOrderRequest.changeset(%StopLossOrderRequest{}, params)

      assert changeset.valid?
      client_ext_changeset = changeset.changes.client_extensions
      assert client_ext_changeset.changes.id == "test-id"
      assert client_ext_changeset.changes.tag == "test-tag"
      assert client_ext_changeset.changes.comment == "test comment"
    end
  end
end
