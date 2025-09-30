defmodule ExOanda.Response.ListPricingTest do
  use ExUnit.Case, async: true

  alias ExOanda.Response.ListPricing

  describe "changeset/2" do
    test "changeset with empty params" do
      params = %{}

      changeset = ListPricing.changeset(%ListPricing{}, params)

      assert is_map(changeset)
    end

    test "changeset with basic params" do
      params = %{
        id: "test-id",
        time: ~U[2023-01-01 00:00:00.000000Z],
        user_id: 123,
        account_id: "account-123",
        batch_id: "batch-123",
        request_id: "request-123",
        last_transaction_id: "transaction-123",
        type: :MARKET_ORDER,
        instrument: "EUR_USD",
        units: 1000,
        price: 1.1000,
        time_in_force: :GTC,
        position_fill: :DEFAULT,
        reason: :CLIENT_ORDER,
        state: :PENDING,
        currency: "USD",
        created_by_user_id: 123,
        created_time: ~U[2023-01-01 00:00:00.000000Z],
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
        balance: 10_000.00,
        pl: 200.00,
        resettable_pl: 150.00,
        financing: -10.50,
        commission: 5.25,
        dividend_adjustment: 0.00,
        guaranteed_execution_fees: 2.50,
        guaranteed_stop_loss_order_mode: :ALLOWED,
        name: "EUR_USD",
        display_name: "EUR/USD",
        pip_location: -4,
        display_precision: 5,
        trade_units_precision: 0,
        minimum_trade_size: 1.0,
        maximum_trailing_stop_distance: 10.0,
        minimum_trailing_stop_distance: 0.0001,
        maximum_position_size: 1_000_000.0,
        maximum_order_units: 1_000_000.0,
        guaranteed_stop_loss_order_premium: 0.0001,
        data: %{"key" => "value"},
        status: :success,
        error_code: nil,
        error_message: nil,
        amount: 1000.0,
        funding_reason: "test funding",
        comment: "test comment",
        reject_reason: "INSUFFICIENT_FUNDS",
        trade_id: "trade-123",
        realized_pl: 50.0,
        base_financing: -2.5,
        quote_financing: -2.5,
        financing_rate: 0.01,
        guaranteed_execution_fee: 1.0,
        quote_guaranteed_execution_fee: 0.5,
        half_spread_cost: 0.25,
        volume: 1000,
        price_range: 0.01,
        related_transaction_ids: ["tx1", "tx2"],
        margin_closeout_unrealized_pl: 100.50,
        margin_closeout_nav: 10_000.00,
        margin_closeout_margin_used: 200.00,
        margin_closeout_percent: 0.02,
        margin_closeout_position_value: 5000.00,
        withdrawal_limit: 5000.00,
        margin_call_margin_used: 200.00,
        margin_call_percent: 0.02,
        margin_call_enter_time: ~U[2023-01-01 00:00:00.000000Z],
        margin_call_extension_count: 0,
        last_margin_call_extension_time: ~U[2023-01-01 00:00:00.000000Z]
      }

      changeset = ListPricing.changeset(%ListPricing{}, params)

      assert is_map(changeset)
    end
  end
end
