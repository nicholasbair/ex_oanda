defmodule ExOanda.CreateTransactionTest do
  use ExUnit.Case, async: true

  alias ExOanda.CreateTransaction

  describe "changeset/2" do
    test "valid changeset with all fields" do
      params = %{
        id: "123",
        time: ~U[2023-01-01 12:00:00.000000Z],
        user_id: 456,
        account_id: "account-123",
        batch_id: "batch-456",
        request_id: "req-789",
        type: :CREATE,
        division_id: 1,
        site_id: 2,
        account_user_id: 789,
        account_number: 12_345,
        home_currency: "USD"
      }

      changeset = CreateTransaction.changeset(%CreateTransaction{}, params)

      assert changeset.valid?
      assert changeset.changes.id == "123"
      assert changeset.changes.time == ~U[2023-01-01 12:00:00.000000Z]
      assert changeset.changes.user_id == 456
      assert changeset.changes.account_id == "account-123"
      assert changeset.changes.batch_id == "batch-456"
      assert changeset.changes.request_id == "req-789"
      assert changeset.changes.division_id == 1
      assert changeset.changes.site_id == 2
      assert changeset.changes.account_user_id == 789
      assert changeset.changes.account_number == 12_345
      assert changeset.changes.home_currency == "USD"
    end

    test "valid changeset with partial fields" do
      params = %{
        id: "123",
        type: :CREATE,
        home_currency: "EUR"
      }

      changeset = CreateTransaction.changeset(%CreateTransaction{}, params)

      assert changeset.valid?
      assert changeset.changes.id == "123"
      assert changeset.changes.home_currency == "EUR"
    end

    test "valid changeset with empty params" do
      changeset = CreateTransaction.changeset(%CreateTransaction{}, %{})

      assert changeset.valid?
      assert changeset.changes == %{}
    end

    test "valid changeset with existing struct" do
      existing = %CreateTransaction{
        id: "existing-id",
        type: :CREATE,
        home_currency: "USD"
      }

      params = %{user_id: 789, division_id: 5}

      changeset = CreateTransaction.changeset(existing, params)

      assert changeset.valid?
      assert changeset.changes.user_id == 789
      assert changeset.changes.division_id == 5
    end

    test "handles invalid field types gracefully" do
      params = %{
        id: 123,  # Should be string
        user_id: "not-a-number",  # Should be integer
        type: "INVALID_TYPE",  # Should be atom
        division_id: "not-a-number"  # Should be integer
      }

      changeset = CreateTransaction.changeset(%CreateTransaction{}, params)

      assert %Ecto.Changeset{} = changeset
    end
  end

  describe "embedded schema" do
    test "has correct primary key configuration" do
      assert CreateTransaction.__schema__(:primary_key) == []
    end

    test "has correct field definitions" do
      fields = CreateTransaction.__schema__(:fields)

      expected_fields = [
        :id, :time, :user_id, :account_id, :batch_id, :request_id, :type,
        :division_id, :site_id, :account_user_id, :account_number, :home_currency
      ]
      assert Enum.all?(expected_fields, &(&1 in fields))
    end
  end
end
