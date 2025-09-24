defmodule ExOanda.TransactionTest do
  use ExUnit.Case, async: true
  alias ExOanda.Transaction

  describe "changeset/2" do
    test "valid changeset with all required fields" do
      params = %{
        id: "transaction-123",
        time: ~U[2023-01-01 00:00:00.000000Z],
        user_id: 12_345,
        account_id: "account-123",
        batch_id: "batch-123",
        request_id: "request-123"
      }

      changeset = Transaction.changeset(%Transaction{}, params)

      assert changeset.valid?
      assert changeset.errors == []
    end

    test "invalid changeset with missing required fields" do
      params = %{}

      changeset = Transaction.changeset(%Transaction{}, params)

      refute changeset.valid?
      assert length(changeset.errors) == 6
      assert {:id, {"can't be blank", [validation: :required]}} in changeset.errors
      assert {:time, {"can't be blank", [validation: :required]}} in changeset.errors
      assert {:user_id, {"can't be blank", [validation: :required]}} in changeset.errors
      assert {:account_id, {"can't be blank", [validation: :required]}} in changeset.errors
      assert {:batch_id, {"can't be blank", [validation: :required]}} in changeset.errors
      assert {:request_id, {"can't be blank", [validation: :required]}} in changeset.errors
    end

    test "changeset with partial data" do
      params = %{
        id: "transaction-123",
        time: ~U[2023-01-01 00:00:00.000000Z],
        user_id: 12_345
      }

      changeset = Transaction.changeset(%Transaction{}, params)

      refute changeset.valid?
      assert {:account_id, {"can't be blank", [validation: :required]}} in changeset.errors
      assert {:batch_id, {"can't be blank", [validation: :required]}} in changeset.errors
      assert {:request_id, {"can't be blank", [validation: :required]}} in changeset.errors
    end

    test "changeset with different data types" do
      params = %{
        id: "transaction-123",
        time: ~U[2023-01-01 00:00:00.000000Z],
        user_id: 12_345,
        account_id: "account-123",
        batch_id: "batch-123",
        request_id: "request-123"
      }

      changeset = Transaction.changeset(%Transaction{}, params)

      assert changeset.valid?
      assert changeset.changes.id == "transaction-123"
      assert changeset.changes.user_id == 12_345
      assert changeset.changes.account_id == "account-123"
      assert changeset.changes.batch_id == "batch-123"
      assert changeset.changes.request_id == "request-123"
    end
  end
end
