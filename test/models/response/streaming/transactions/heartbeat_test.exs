defmodule ExOanda.Response.TransactionHeartbeatTest do
  use ExUnit.Case, async: true
  alias ExOanda.Response.TransactionHeartbeat

  describe "changeset/2" do
    test "valid changeset with all fields" do
      params = %{
        last_transaction_id: "transaction-123",
        time: ~U[2023-01-01 00:00:00.000000Z],
        type: :HEARTBEAT
      }

      changeset = TransactionHeartbeat.changeset(%TransactionHeartbeat{}, params)

      assert changeset.valid?
      assert changeset.errors == []
    end

    test "valid changeset with minimal required fields" do
      params = %{
        last_transaction_id: "transaction-456",
        time: ~U[2023-01-01 12:30:45.123456Z]
      }

      changeset = TransactionHeartbeat.changeset(%TransactionHeartbeat{}, params)

      assert changeset.valid?
      assert changeset.errors == []
      assert changeset.data.type == :HEARTBEAT
    end

    test "valid changeset with string type" do
      params = %{
        last_transaction_id: "transaction-789",
        time: ~U[2023-01-01 00:00:00.000000Z],
        type: "HEARTBEAT"
      }

      changeset = TransactionHeartbeat.changeset(%TransactionHeartbeat{}, params)

      assert changeset.valid?
      assert changeset.errors == []
      assert changeset.data.type == :HEARTBEAT
    end

    test "valid changeset with empty params" do
      params = %{}

      changeset = TransactionHeartbeat.changeset(%TransactionHeartbeat{}, params)

      assert changeset.valid?
      assert changeset.errors == []
      assert changeset.data.type == :HEARTBEAT
    end

    test "valid changeset with nil values" do
      params = %{
        last_transaction_id: nil,
        time: nil,
        type: nil
      }

      changeset = TransactionHeartbeat.changeset(%TransactionHeartbeat{}, params)

      assert changeset.valid?
      assert changeset.errors == []
    end

    test "changeset with different time formats" do
      params = %{
        last_transaction_id: "transaction-123",
        time: ~U[2023-01-01 00:00:00.000000Z]
      }

      changeset = TransactionHeartbeat.changeset(%TransactionHeartbeat{}, params)
      assert changeset.valid?

      params = %{
        last_transaction_id: "transaction-456",
        time: ~N[2023-01-01 00:00:00.000000]
      }

      changeset = TransactionHeartbeat.changeset(%TransactionHeartbeat{}, params)
      assert changeset.valid?
    end

    test "changeset with different type values" do
      params = %{
        last_transaction_id: "transaction-123",
        time: ~U[2023-01-01 00:00:00.000000Z],
        type: :HEARTBEAT
      }

      changeset = TransactionHeartbeat.changeset(%TransactionHeartbeat{}, params)
      assert changeset.valid?
      assert changeset.data.type == :HEARTBEAT

      params = %{
        last_transaction_id: "transaction-456",
        time: ~U[2023-01-01 00:00:00.000000Z],
        type: "HEARTBEAT"
      }

      changeset = TransactionHeartbeat.changeset(%TransactionHeartbeat{}, params)
      assert changeset.valid?
      assert changeset.data.type == :HEARTBEAT
    end

    test "changeset preserves existing struct values" do
      existing_struct = %TransactionHeartbeat{
        last_transaction_id: "existing-transaction",
        time: ~U[2023-01-01 00:00:00.000000Z],
        type: :HEARTBEAT
      }

      params = %{
        last_transaction_id: "new-transaction-123"
      }

      changeset = TransactionHeartbeat.changeset(existing_struct, params)

      assert changeset.valid?
      assert changeset.changes.last_transaction_id == "new-transaction-123"
      assert changeset.data.time == ~U[2023-01-01 00:00:00.000000Z]
      assert changeset.data.type == :HEARTBEAT
    end

    test "changeset with partial updates" do
      existing_struct = %TransactionHeartbeat{
        last_transaction_id: "existing-transaction",
        time: ~U[2023-01-01 00:00:00.000000Z],
        type: :HEARTBEAT
      }

      params = %{
        time: ~U[2023-01-02 12:00:00.000000Z]
      }

      changeset = TransactionHeartbeat.changeset(existing_struct, params)

      assert changeset.valid?
      assert changeset.changes.time == ~U[2023-01-02 12:00:00.000000Z]
      assert changeset.data.last_transaction_id == "existing-transaction"
      assert changeset.data.type == :HEARTBEAT
    end
  end

  describe "schema structure" do
    test "has correct fields" do
      struct = %TransactionHeartbeat{}

      assert Map.has_key?(struct, :last_transaction_id)
      assert Map.has_key?(struct, :time)
      assert Map.has_key?(struct, :type)
    end

    test "default type value" do
      struct = %TransactionHeartbeat{}
      assert struct.type == :HEARTBEAT
    end

    test "can be created with all fields" do
      struct = %TransactionHeartbeat{
        last_transaction_id: "transaction-123",
        time: ~U[2023-01-01 00:00:00.000000Z],
        type: :HEARTBEAT
      }

      assert struct.last_transaction_id == "transaction-123"
      assert struct.time == ~U[2023-01-01 00:00:00.000000Z]
      assert struct.type == :HEARTBEAT
    end
  end
end
