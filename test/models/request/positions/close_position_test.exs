defmodule ExOanda.Request.ClosePositionTest do
  use ExUnit.Case, async: true

  alias ExOanda.Request.ClosePosition

  describe "changeset/2" do
    test "changeset with empty params" do
      params = %{}

      changeset = ClosePosition.changeset(%ClosePosition{}, params)

      assert is_map(changeset)
    end

    test "changeset with basic params" do
      params = %{
        long_units: 1000.0,
        short_units: 500.0
      }

      changeset = ClosePosition.changeset(%ClosePosition{}, params)

      assert is_map(changeset)
    end

    test "changeset with long_units only" do
      params = %{
        long_units: 1000.0
      }

      changeset = ClosePosition.changeset(%ClosePosition{}, params)

      # This test ensures the changeset function doesn't crash with only long_units
      assert is_map(changeset)
    end

    test "changeset with short_units only" do
      params = %{
        short_units: 500.0
      }

      changeset = ClosePosition.changeset(%ClosePosition{}, params)

      # This test ensures the changeset function doesn't crash with only short_units
      assert is_map(changeset)
    end

    test "changeset with neither long_units nor short_units should add validation error" do
      params = %{}

      changeset = ClosePosition.changeset(%ClosePosition{}, params)

      # This test ensures the validation error is added when neither field is present
      assert changeset.errors[:long_units] == {"at least one of [:long_units, :short_units] must be present", []}
      refute changeset.valid?
    end

    test "changeset with nil values should add validation error" do
      params = %{
        long_units: nil,
        short_units: nil
      }

      changeset = ClosePosition.changeset(%ClosePosition{}, params)

      # This test ensures the validation error is added when both fields are nil
      assert changeset.errors[:long_units] == {"at least one of [:long_units, :short_units] must be present", []}
      refute changeset.valid?
    end

    test "changeset with valid long_units should pass validation" do
      params = %{
        long_units: 1000.0
      }

      changeset = ClosePosition.changeset(%ClosePosition{}, params)

      # This test ensures the validation passes when at least one field is present
      assert changeset.valid?
      assert changeset.errors == []
    end

    test "changeset with valid short_units should pass validation" do
      params = %{
        short_units: 500.0
      }

      changeset = ClosePosition.changeset(%ClosePosition{}, params)

      # This test ensures the validation passes when at least one field is present
      assert changeset.valid?
      assert changeset.errors == []
    end
  end
end
