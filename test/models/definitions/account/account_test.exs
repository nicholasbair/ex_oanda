defmodule ExOanda.AccountTest do
  use ExUnit.Case, async: true
  alias ExOanda.Account

  describe "changeset/2" do
    test "valid changeset with all required fields" do
      params = %{
        id: "test-account-id",
        alias: "Test Account",
        currency: "USD",
        created_by_user_id: 12_345,
        created_time: ~U[2023-01-01 00:00:00.000000Z],
        resettabled_pl_time: ~U[2023-01-01 00:00:00.000000Z],
        margin_rate: 0.02,
        open_trade_count: 5,
        open_position_count: 3,
        pending_order_count: 2,
        hedging_enabled: true,
        unrealized_pl: 100.50,
        nav: 10_000.00,
        margin_used: 200.00,
        margin_available: 9800.00,
        position_value: 5000.00,
        margin_closeout_unrealized_pl: 50.25,
        margin_closeout_nav: 9950.25,
        margin_closeout_margin_used: 199.00,
        margin_closeout_percent: 0.02,
        margin_closeout_position_value: 4950.25,
        withdrawal_limit: 5000.00,
        margin_call_margin_used: 150.00,
        margin_call_percent: 0.015,
        balance: 10_000.00,
        pl: 200.00,
        resettable_pl: 150.00,
        financing: -10.50,
        commission: 5.25,
        dividend_adjustment: 0.00,
        guaranteed_execution_fees: 2.50,
        margin_call_enter_time: ~U[2023-01-01 00:00:00.000000Z],
        margin_call_extension_count: 0,
        last_margin_call_extension_time: ~U[2023-01-01 00:00:00.000000Z],
        last_transaction_id: "transaction-123",
        guaranteed_stop_loss_order_mode: :ALLOWED
      }

      changeset = Account.changeset(%Account{}, params)

      assert changeset.valid?
      assert changeset.errors == []
    end

    test "invalid changeset with missing required fields" do
      params = %{}

      changeset = Account.changeset(%Account{}, params)

      refute changeset.valid?
      assert length(changeset.errors) > 0
    end

    test "changeset with embedded fields" do
      params = %{
        id: "test-account-id",
        alias: "Test Account",
        currency: "USD",
        created_by_user_id: 12_345,
        created_time: ~U[2023-01-01 00:00:00.000000Z],
        resettabled_pl_time: ~U[2023-01-01 00:00:00.000000Z],
        margin_rate: 0.02,
        open_trade_count: 5,
        open_position_count: 3,
        pending_order_count: 2,
        hedging_enabled: true,
        unrealized_pl: 100.50,
        nav: 10_000.00,
        margin_used: 200.00,
        margin_available: 9800.00,
        position_value: 5000.00,
        margin_closeout_unrealized_pl: 50.25,
        margin_closeout_nav: 9950.25,
        margin_closeout_margin_used: 199.00,
        margin_closeout_percent: 0.02,
        margin_closeout_position_value: 4950.25,
        withdrawal_limit: 5000.00,
        margin_call_margin_used: 150.00,
        margin_call_percent: 0.015,
        balance: 10_000.00,
        pl: 200.00,
        resettable_pl: 150.00,
        financing: -10.50,
        commission: 5.25,
        dividend_adjustment: 0.00,
        guaranteed_execution_fees: 2.50,
        margin_call_enter_time: ~U[2023-01-01 00:00:00.000000Z],
        margin_call_extension_count: 0,
        last_margin_call_extension_time: ~U[2023-01-01 00:00:00.000000Z],
        last_transaction_id: "transaction-123",
        guaranteed_stop_loss_order_mode: :ALLOWED,
        guaranteed_stop_loss_order_parameters: %{
          mutability_market_open: :FIXED,
          mutability_market_halted: :FIXED
        },
        trades: [
          %{
            id: "trade-1",
            instrument: "EUR_USD",
            price: 1.1000,
            open_time: ~U[2023-01-01 00:00:00.000000Z],
            state: :OPEN,
            initial_units: 1000,
            initial_margin_required: 20.00,
            current_units: 1000,
            realized_pl: 0.00,
            unrealized_pl: 10.50,
            margin_used: 20.00
          }
        ],
        positions: [
          %{
            instrument: "EUR_USD",
            pl: 10.50,
            resettable_pl: 10.50,
            financing: 0.0,
            long: %{
              units: 1000,
              average_price: 1.1000,
              trade_ids: [],
              pl: 10.50,
              resettable_pl: 10.50,
              financing: 0.0
            },
            short: %{
              units: 0,
              average_price: 0.0,
              trade_ids: [],
              pl: 0.0,
              resettable_pl: 0.0,
              financing: 0.0
            }
          }
        ],
        orders: [
          %{
            id: "order-1",
            create_time: ~U[2023-01-01 00:00:00.000000Z],
            state: :PENDING,
            client_extensions: %{
              id: "client-id",
              comment: "Test order"
            }
          }
        ]
      }

      changeset = Account.changeset(%Account{}, params)

      assert changeset.valid?
      assert changeset.errors == []
    end

    test "changeset with invalid enum values" do
      params = %{
        id: "test-account-id",
        alias: "Test Account",
        currency: "USD",
        created_by_user_id: 12_345,
        created_time: ~U[2023-01-01 00:00:00.000000Z],
        resettabled_pl_time: ~U[2023-01-01 00:00:00.000000Z],
        margin_rate: 0.02,
        open_trade_count: 5,
        open_position_count: 3,
        pending_order_count: 2,
        hedging_enabled: true,
        unrealized_pl: 100.50,
        nav: 10_000.00,
        margin_used: 200.00,
        margin_available: 9800.00,
        position_value: 5000.00,
        margin_closeout_unrealized_pl: 50.25,
        margin_closeout_nav: 9950.25,
        margin_closeout_margin_used: 199.00,
        margin_closeout_percent: 0.02,
        margin_closeout_position_value: 4950.25,
        withdrawal_limit: 5000.00,
        margin_call_margin_used: 150.00,
        margin_call_percent: 0.015,
        balance: 10_000.00,
        pl: 200.00,
        resettable_pl: 150.00,
        financing: -10.50,
        commission: 5.25,
        dividend_adjustment: 0.00,
        guaranteed_execution_fees: 2.50,
        margin_call_enter_time: ~U[2023-01-01 00:00:00.000000Z],
        margin_call_extension_count: 0,
        last_margin_call_extension_time: ~U[2023-01-01 00:00:00.000000Z],
        last_transaction_id: "transaction-123",
        guaranteed_stop_loss_order_mode: :INVALID_MODE
      }

      changeset = Account.changeset(%Account{}, params)

      refute changeset.valid?
      assert guaranteed_stop_loss_order_mode: {"is invalid", [validation: :inclusion, enum: ["ALLOWED", "DISABLED", "REQUIRED"]]} in changeset.errors
    end
  end
end
