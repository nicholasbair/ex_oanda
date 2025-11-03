defmodule ExOanda.LimitOrderRequestTest do
  use ExUnit.Case, async: true
  alias ExOanda.LimitOrderRequest

  describe "changeset/2" do
    test "valid changeset with required fields" do
      params = %{
        type: :LIMIT,
        instrument: "EUR_USD",
        units: 1000,
        price: 1.1000
      }

      changeset = LimitOrderRequest.changeset(%LimitOrderRequest{}, params)

      assert changeset.valid?
      assert changeset.errors == []
      assert changeset.data.time_in_force == :GTC
    end

    test "valid changeset with all fields" do
      params = %{
        type: :LIMIT,
        instrument: "EUR_USD",
        units: 1000,
        price: 1.1000,
        time_in_force: :GTD,
        gtd_time: ~U[2023-12-31 23:59:59.000000Z],
        position_fill: :DEFAULT,
        trigger_condition: :DEFAULT,
        client_extensions: %{
          id: "client-id",
          comment: "Test order"
        }
      }

      changeset = LimitOrderRequest.changeset(%LimitOrderRequest{}, params)

      assert changeset.valid?
      assert changeset.errors == []
    end

    test "requires price" do
      params = %{
        type: :LIMIT,
        instrument: "EUR_USD",
        units: 1000
      }

      changeset = LimitOrderRequest.changeset(%LimitOrderRequest{}, params)

      refute changeset.valid?
      assert length(changeset.errors) > 0
    end

    test "default time_in_force is GTC" do
      params = %{
        type: :LIMIT,
        instrument: "EUR_USD",
        units: 1000,
        price: 1.1000
      }

      changeset = LimitOrderRequest.changeset(%LimitOrderRequest{}, params)

      assert changeset.valid?
      assert changeset.data.time_in_force == :GTC
    end

    test "invalid time_in_force for limit order" do
      params = %{
        type: :LIMIT,
        instrument: "EUR_USD",
        units: 1000,
        price: 1.1000,
        time_in_force: :FOK
      }

      changeset = LimitOrderRequest.changeset(%LimitOrderRequest{}, params)

      refute changeset.valid?
      assert length(changeset.errors) > 0
    end
  end
end
