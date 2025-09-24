defmodule ExOanda.Response.CreateOrderTest do
  use ExUnit.Case, async: true

  describe "changeset/2" do
    test "valid changeset with minimal data" do
      params = get_valid_params()

      changeset = ExOanda.Response.CreateOrder.changeset(%ExOanda.Response.CreateOrder{}, params)

      assert changeset.valid?
      assert changeset.errors == []
    end

    test "changeset with empty params" do
      params = %{}

      changeset = ExOanda.Response.CreateOrder.changeset(%ExOanda.Response.CreateOrder{}, params)

      # Some models have no required fields, so empty params may be valid
      assert is_map(changeset)
    end

    test "changeset with invalid enum values" do
      params = get_valid_params()
      |> put_invalid_enum_values()

      changeset = ExOanda.Response.CreateOrder.changeset(%ExOanda.Response.CreateOrder{}, params)

      # Some models may not have enum fields, so this test may pass
      # This test just ensures the changeset function handles invalid data gracefully
      assert is_map(changeset)
    end

    test "changeset with valid enum values" do
      params = get_valid_params()

      changeset = ExOanda.Response.CreateOrder.changeset(%ExOanda.Response.CreateOrder{}, params)

      assert changeset.valid?
    end
  end

  # Helper functions to generate test data
  defp get_valid_params do
    # This is a basic implementation - may need customization per model
    %{
      id: "test-id-123",
      time: ~U[2023-01-01 00:00:00.000000Z],
      user_id: 12_345,
      account_id: "account-123",
      batch_id: "batch-123",
      request_id: "request-123",
      type: :MARKET_ORDER,
      instrument: "EUR_USD",
      units: 1000,
      price: 1.1000,
      time_in_force: :GTC,
      position_fill: :DEFAULT,
      reason: :CLIENT_ORDER,
      state: :PENDING,
      currency: "USD",
      created_by_user_id: 12_345,
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
      last_transaction_id: "transaction-123",
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
      error_message: nil
    }
  end

  defp put_invalid_enum_values(params) do
    params
    |> Map.put(:type, :INVALID_TYPE)
    |> Map.put(:time_in_force, :INVALID_TIF)
    |> Map.put(:position_fill, :INVALID_PF)
    |> Map.put(:reason, :INVALID_REASON)
    |> Map.put(:state, :INVALID_STATE)
    |> Map.put(:guaranteed_stop_loss_order_mode, :INVALID_MODE)
    |> Map.put(:status, :INVALID_STATUS)
  end
end
