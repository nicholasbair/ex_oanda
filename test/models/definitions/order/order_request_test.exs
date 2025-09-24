defmodule ExOanda.OrderRequestTest do
  use ExUnit.Case, async: true
  alias ExOanda.OrderRequest

  describe "changeset/2" do
    test "valid changeset with minimal required fields" do
      params = %{
        type: :MARKET,
        instrument: "EUR_USD",
        units: 1000
      }

      changeset = OrderRequest.changeset(%OrderRequest{}, params)

      assert changeset.valid?
      assert changeset.errors == []
    end

    test "valid changeset with all fields" do
      params = %{
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
        },
        guaranteed_stop_loss_on_fill: %{
          price: "1.0750",
          time_in_force: :GTC
        },
        trailing_stop_loss_on_fill: %{
          distance: "0.0100",
          time_in_force: :GTC
        },
        trade_client_extensions: %{
          id: "trade-client-id",
          comment: "Trade comment"
        }
      }

      changeset = OrderRequest.changeset(%OrderRequest{}, params)

      assert changeset.valid?
      assert changeset.errors == []
    end

    test "changeset with default type" do
      params = %{
        instrument: "EUR_USD",
        units: 1000
      }

      changeset = OrderRequest.changeset(%OrderRequest{}, params)

      assert changeset.valid?
      assert changeset.data.type == :MARKET
    end

    test "changeset with invalid enum values" do
      params = %{
        type: :INVALID_TYPE,
        instrument: "EUR_USD",
        units: 1000,
        time_in_force: :INVALID_TIF,
        position_fill: :INVALID_PF,
        trigger_condition: :INVALID_TC
      }

      changeset = OrderRequest.changeset(%OrderRequest{}, params)

      refute changeset.valid?
      assert length(changeset.errors) > 0
    end

    test "changeset with valid enum values" do
      valid_types = [:MARKET, :LIMIT, :STOP, :MARKET_IF_TOUCHED, :TAKE_PROFIT, :STOP_LOSS, :GUARANTEED_STOP_LOSS, :TRAILING_STOP_LOSS]
      valid_time_in_force = [:GTC, :GTD, :GFD, :FOK, :IOC]
      valid_position_fill = [:DEFAULT, :REDUCE_ONLY]
      valid_trigger_conditions = [:DEFAULT, :INVERSE, :BID, :ASK, :MID]

      for type <- valid_types do
        params = %{
          type: type,
          instrument: "EUR_USD",
          units: 1000
        }

        changeset = OrderRequest.changeset(%OrderRequest{}, params)
        assert changeset.valid?, "Type #{type} should be valid"
      end

      for tif <- valid_time_in_force do
        params = %{
          type: :MARKET,
          instrument: "EUR_USD",
          units: 1000,
          time_in_force: tif
        }

        changeset = OrderRequest.changeset(%OrderRequest{}, params)
        assert changeset.valid?, "Time in force #{tif} should be valid"
      end

      for pf <- valid_position_fill do
        params = %{
          type: :MARKET,
          instrument: "EUR_USD",
          units: 1000,
          position_fill: pf
        }

        changeset = OrderRequest.changeset(%OrderRequest{}, params)
        assert changeset.valid?, "Position fill #{pf} should be valid"
      end

      for tc <- valid_trigger_conditions do
        params = %{
          type: :MARKET,
          instrument: "EUR_USD",
          units: 1000,
          trigger_condition: tc
        }

        changeset = OrderRequest.changeset(%OrderRequest{}, params)
        assert changeset.valid?, "Trigger condition #{tc} should be valid"
      end
    end
  end
end
