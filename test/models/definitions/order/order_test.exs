defmodule ExOanda.OrderTest do
  use ExUnit.Case, async: true
  alias ExOanda.Order

  describe "changeset/2" do
    test "valid changeset with all required fields" do
      params = %{
        id: "order-123",
        create_time: ~U[2023-01-01 00:00:00.000000Z],
        state: :PENDING
      }

      changeset = Order.changeset(%Order{}, params)

      assert changeset.valid?
      assert changeset.errors == []
    end

    test "valid changeset with client extensions" do
      params = %{
        id: "order-123",
        create_time: ~U[2023-01-01 00:00:00.000000Z],
        state: :FILLED,
        client_extensions: %{
          id: "client-id-123",
          comment: "Test order comment"
        }
      }

      changeset = Order.changeset(%Order{}, params)

      assert changeset.valid?
      assert changeset.errors == []
    end

    test "invalid changeset with missing required fields" do
      params = %{}

      changeset = Order.changeset(%Order{}, params)

      refute changeset.valid?
      assert length(changeset.errors) == 3
      assert {:id, {"can't be blank", [validation: :required]}} in changeset.errors
      assert {:create_time, {"can't be blank", [validation: :required]}} in changeset.errors
      assert {:state, {"can't be blank", [validation: :required]}} in changeset.errors
    end

    test "invalid changeset with invalid enum values" do
      params = %{
        id: "order-123",
        create_time: ~U[2023-01-01 00:00:00.000000Z],
        state: :INVALID_STATE
      }

      changeset = Order.changeset(%Order{}, params)

      refute changeset.valid?
      assert Keyword.has_key?(changeset.errors, :state)
    end

    test "changeset with all valid enum values" do
      valid_states = [:PENDING, :FILLED, :TRIGGERED, :CANCELLED]

      for state <- valid_states do
        params = %{
          id: "order-123",
          create_time: ~U[2023-01-01 00:00:00.000000Z],
          state: state
        }

        changeset = Order.changeset(%Order{}, params)
        assert changeset.valid?, "State #{state} should be valid"
      end
    end
  end
end
