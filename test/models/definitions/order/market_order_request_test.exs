defmodule ExOanda.MarketOrderRequestTest do
  use ExUnit.Case, async: true
  alias ExOanda.MarketOrderRequest

  describe "changeset/2" do
    test "valid changeset with minimal required fields" do
      params = %{
        type: :MARKET,
        instrument: "EUR_USD",
        units: 1000
      }

      changeset = MarketOrderRequest.changeset(%MarketOrderRequest{}, params)

      assert changeset.valid?
      assert changeset.errors == []
      assert changeset.data.time_in_force == :FOK
    end

    test "valid changeset with all fields" do
      params = %{
        type: :MARKET,
        instrument: "EUR_USD",
        units: 1000,
        time_in_force: :IOC,
        price_bound: 1.1050,
        position_fill: :DEFAULT,
        client_extensions: %{
          id: "client-id",
          comment: "Test order"
        }
      }

      changeset = MarketOrderRequest.changeset(%MarketOrderRequest{}, params)

      assert changeset.valid?
      assert changeset.errors == []
    end

    test "default time_in_force is FOK" do
      params = %{
        instrument: "EUR_USD",
        units: 1000
      }

      changeset = MarketOrderRequest.changeset(%MarketOrderRequest{}, params)

      assert changeset.valid?
      assert changeset.data.time_in_force == :FOK
    end

    test "invalid time_in_force for market order" do
      params = %{
        type: :MARKET,
        instrument: "EUR_USD",
        units: 1000,
        time_in_force: :GTC
      }

      changeset = MarketOrderRequest.changeset(%MarketOrderRequest{}, params)

      refute changeset.valid?
      refute Enum.empty?(changeset.errors)
    end

    test "requires instrument and units" do
      params = %{
        type: :MARKET
      }

      changeset = MarketOrderRequest.changeset(%MarketOrderRequest{}, params)

      refute changeset.valid?
      refute Enum.empty?(changeset.errors)
    end
  end
end
