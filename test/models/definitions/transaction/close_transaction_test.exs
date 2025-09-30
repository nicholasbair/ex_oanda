defmodule ExOanda.CloseTransactionTest do
  use ExUnit.Case, async: true

  alias ExOanda.CloseTransaction

  describe "changeset/2" do
    test "valid changeset with all fields" do
      params = %{
        id: "123",
        time: ~U[2023-01-01 12:00:00.000000Z],
        user_id: 456,
        account_id: "account-123",
        batch_id: "batch-456",
        request_id: "req-789",
        type: :CLOSE
      }

      changeset = CloseTransaction.changeset(%CloseTransaction{}, params)

      assert changeset.valid?
      assert changeset.changes.id == "123"
      assert changeset.changes.time == ~U[2023-01-01 12:00:00.000000Z]
      assert changeset.changes.user_id == 456
      assert changeset.changes.account_id == "account-123"
      assert changeset.changes.batch_id == "batch-456"
      assert changeset.changes.request_id == "req-789"
    end

    test "valid changeset with partial fields" do
      params = %{
        id: "123",
        type: :CLOSE
      }

      changeset = CloseTransaction.changeset(%CloseTransaction{}, params)

      assert changeset.valid?
      assert changeset.changes.id == "123"
    end

    test "valid changeset with empty params" do
      changeset = CloseTransaction.changeset(%CloseTransaction{}, %{})

      assert changeset.valid?
      assert changeset.changes == %{}
    end

    test "valid changeset with existing struct" do
      existing = %CloseTransaction{
        id: "existing-id",
        type: :CLOSE
      }

      params = %{user_id: 789}

      changeset = CloseTransaction.changeset(existing, params)

      assert changeset.valid?
      assert changeset.changes.user_id == 789
    end

    test "handles invalid field types gracefully" do
      params = %{
        id: 123,  # Should be string
        user_id: "not-a-number",  # Should be integer
        type: "INVALID_TYPE"  # Should be atom
      }

      changeset = CloseTransaction.changeset(%CloseTransaction{}, params)

      assert %Ecto.Changeset{} = changeset
    end
  end

  describe "embedded schema" do
    test "has correct primary key configuration" do
      assert CloseTransaction.__schema__(:primary_key) == []
    end

    test "has correct field definitions" do
      fields = CloseTransaction.__schema__(:fields)

      expected_fields = [:id, :time, :user_id, :account_id, :batch_id, :request_id, :type]
      assert Enum.all?(expected_fields, &(&1 in fields))
    end
  end
end
