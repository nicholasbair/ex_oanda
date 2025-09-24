defmodule ExOanda.MarketOrderTransactionTest do
  use ExUnit.Case, async: true
  alias ExOanda.MarketOrderTransaction

  describe "changeset/2" do
    test "valid changeset with minimal required fields" do
      params = %{
        id: "transaction-123",
        time: ~U[2023-01-01 00:00:00.000000Z],
        user_id: 12_345,
        account_id: "account-123",
        batch_id: "batch-123",
        request_id: "request-123",
        type: :MARKET_ORDER,
        instrument: "EUR_USD",
        units: 1000.0,
        time_in_force: :GTC,
        position_fill: :DEFAULT,
        reason: :CLIENT_ORDER
      }

      changeset = MarketOrderTransaction.changeset(%MarketOrderTransaction{}, params)

      assert changeset.valid?
      assert changeset.errors == []
    end

    test "valid changeset with all fields" do
      params = %{
        id: "transaction-123",
        time: ~U[2023-01-01 00:00:00.000000Z],
        user_id: 12_345,
        account_id: "account-123",
        batch_id: "batch-123",
        request_id: "request-123",
        type: :MARKET_ORDER,
        instrument: "EUR_USD",
        units: 1000.0,
        time_in_force: :GTC,
        price_bound: 1.1000,
        position_fill: :DEFAULT,
        reason: :CLIENT_ORDER,
        trade_close: %{
          trade_id: "trade-123",
          client_trade_id: "client-trade-123"
        },
        long_position_closeout: %{
          units: "1000",
          client_id: "client-123"
        },
        short_position_closeout: %{
          units: "500",
          client_id: "client-456"
        },
        margin_closeout: %{
          reason: :MARGIN_CHECK_VIOLATION
        },
        delayed_trade_close: %{
          trade_id: "trade-456",
          client_trade_id: "client-trade-456"
        },
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
        trailing_stop_loss_on_fill: %{
          distance: "0.0100",
          time_in_force: :GTC
        },
        guaranteed_stop_loss_on_fill: %{
          price: "1.0750",
          time_in_force: :GTC
        },
        trade_client_extensions: %{
          id: "trade-client-id",
          comment: "Trade comment"
        }
      }

      changeset = MarketOrderTransaction.changeset(%MarketOrderTransaction{}, params)

      assert changeset.valid?
      assert changeset.errors == []
    end

    test "changeset with invalid enum values" do
      params = %{
        id: "transaction-123",
        time: ~U[2023-01-01 00:00:00.000000Z],
        user_id: 12_345,
        account_id: "account-123",
        batch_id: "batch-123",
        request_id: "request-123",
        type: :INVALID_TYPE,
        instrument: "EUR_USD",
        units: 1000.0,
        time_in_force: :INVALID_TIF,
        position_fill: :INVALID_PF,
        reason: :INVALID_REASON
      }

      changeset = MarketOrderTransaction.changeset(%MarketOrderTransaction{}, params)

      refute changeset.valid?
      assert length(changeset.errors) > 0
    end

    test "changeset with valid enum values" do
      valid_time_in_force = [:GTC, :GTD, :GFD, :FOK, :IOC]
      valid_position_fill = [:DEFAULT, :REDUCE_FIRST, :REDUCE_ONLY, :OPEN_ONLY]
      valid_reasons = [:CLIENT_ORDER, :TRADE_CLOSE, :POSITION_CLOSEOUT, :MARGIN_CLOSEOUT, :DELAYED_TRADE_CLOSE]

      for tif <- valid_time_in_force do
        params = %{
          id: "transaction-123",
          time: ~U[2023-01-01 00:00:00.000000Z],
          user_id: 12_345,
          account_id: "account-123",
          batch_id: "batch-123",
          request_id: "request-123",
          type: :MARKET_ORDER,
          instrument: "EUR_USD",
          units: 1000.0,
          time_in_force: tif,
          position_fill: :DEFAULT,
          reason: :CLIENT_ORDER
        }

        changeset = MarketOrderTransaction.changeset(%MarketOrderTransaction{}, params)
        assert changeset.valid?, "Time in force #{tif} should be valid"
      end

      for pf <- valid_position_fill do
        params = %{
          id: "transaction-123",
          time: ~U[2023-01-01 00:00:00.000000Z],
          user_id: 12_345,
          account_id: "account-123",
          batch_id: "batch-123",
          request_id: "request-123",
          type: :MARKET_ORDER,
          instrument: "EUR_USD",
          units: 1000.0,
          time_in_force: :GTC,
          position_fill: pf,
          reason: :CLIENT_ORDER
        }

        changeset = MarketOrderTransaction.changeset(%MarketOrderTransaction{}, params)
        assert changeset.valid?, "Position fill #{pf} should be valid"
      end

      for reason <- valid_reasons do
        params = %{
          id: "transaction-123",
          time: ~U[2023-01-01 00:00:00.000000Z],
          user_id: 12_345,
          account_id: "account-123",
          batch_id: "batch-123",
          request_id: "request-123",
          type: :MARKET_ORDER,
          instrument: "EUR_USD",
          units: 1000.0,
          time_in_force: :GTC,
          position_fill: :DEFAULT,
          reason: reason
        }

        changeset = MarketOrderTransaction.changeset(%MarketOrderTransaction{}, params)
        assert changeset.valid?, "Reason #{reason} should be valid"
      end
    end
  end
end
