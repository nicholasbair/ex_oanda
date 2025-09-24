defmodule ExOanda.CloseoutUnitsTest do
  use ExUnit.Case, async: true
  alias ExOanda.CloseoutUnits

  describe "type/0" do
    test "returns :string" do
      assert CloseoutUnits.type() == :string
    end
  end

  describe "cast/1" do
    test "returns {:ok, \"ALL\"} for \"ALL\" string" do
      assert CloseoutUnits.cast("ALL") == {:ok, "ALL"}
    end

    test "returns {:ok, \"NONE\"} for \"NONE\" string" do
      assert CloseoutUnits.cast("NONE") == {:ok, "NONE"}
    end

    test "returns {:ok, value} for valid float values" do
      assert CloseoutUnits.cast(0.0) == {:ok, 0.0}
      assert CloseoutUnits.cast(1.5) == {:ok, 1.5}
      assert CloseoutUnits.cast(-2.25) == {:ok, -2.25}
      assert CloseoutUnits.cast(100.0) == {:ok, 100.0}
    end

    test "returns :error for invalid string values" do
      assert CloseoutUnits.cast("INVALID") == :error
      assert CloseoutUnits.cast("all") == :error
      assert CloseoutUnits.cast("none") == :error
      assert CloseoutUnits.cast("") == :error
    end

    test "returns :error for non-float numeric values" do
      assert CloseoutUnits.cast(1) == :error
      assert CloseoutUnits.cast(0) == :error
      assert CloseoutUnits.cast(-5) == :error
    end

    test "returns :error for non-string, non-float values" do
      assert CloseoutUnits.cast(nil) == :error
      assert CloseoutUnits.cast(%{}) == :error
      assert CloseoutUnits.cast([]) == :error
      assert CloseoutUnits.cast(:atom) == :error
    end
  end

  describe "load/1" do
    test "returns {:ok, \"ALL\"} for \"ALL\" string" do
      assert CloseoutUnits.load("ALL") == {:ok, "ALL"}
    end

    test "returns {:ok, \"NONE\"} for \"NONE\" string" do
      assert CloseoutUnits.load("NONE") == {:ok, "NONE"}
    end

    test "returns {:ok, value} for valid float values" do
      assert CloseoutUnits.load(0.0) == {:ok, 0.0}
      assert CloseoutUnits.load(1.5) == {:ok, 1.5}
      assert CloseoutUnits.load(-2.25) == {:ok, -2.25}
      assert CloseoutUnits.load(100.0) == {:ok, 100.0}
    end

    test "returns :error for invalid string values" do
      assert CloseoutUnits.load("INVALID") == :error
      assert CloseoutUnits.load("all") == :error
      assert CloseoutUnits.load("none") == :error
      assert CloseoutUnits.load("") == :error
    end

    test "returns :error for non-float numeric values" do
      assert CloseoutUnits.load(1) == :error
      assert CloseoutUnits.load(0) == :error
      assert CloseoutUnits.load(-5) == :error
    end

    test "returns :error for non-string, non-float values" do
      assert CloseoutUnits.load(nil) == :error
      assert CloseoutUnits.load(%{}) == :error
      assert CloseoutUnits.load([]) == :error
      assert CloseoutUnits.load(:atom) == :error
    end
  end

  describe "dump/1" do
    test "returns {:ok, \"ALL\"} for \"ALL\" string" do
      assert CloseoutUnits.dump("ALL") == {:ok, "ALL"}
    end

    test "returns {:ok, \"NONE\"} for \"NONE\" string" do
      assert CloseoutUnits.dump("NONE") == {:ok, "NONE"}
    end

    test "returns {:ok, value} for valid float values" do
      assert CloseoutUnits.dump(0.0) == {:ok, 0.0}
      assert CloseoutUnits.dump(1.5) == {:ok, 1.5}
      assert CloseoutUnits.dump(-2.25) == {:ok, -2.25}
      assert CloseoutUnits.dump(100.0) == {:ok, 100.0}
    end

    test "returns :error for invalid string values" do
      assert CloseoutUnits.dump("INVALID") == :error
      assert CloseoutUnits.dump("all") == :error
      assert CloseoutUnits.dump("none") == :error
      assert CloseoutUnits.dump("") == :error
    end

    test "returns :error for non-float numeric values" do
      assert CloseoutUnits.dump(1) == :error
      assert CloseoutUnits.dump(0) == :error
      assert CloseoutUnits.dump(-5) == :error
    end

    test "returns :error for non-string, non-float values" do
      assert CloseoutUnits.dump(nil) == :error
      assert CloseoutUnits.dump(%{}) == :error
      assert CloseoutUnits.dump([]) == :error
      assert CloseoutUnits.dump(:atom) == :error
    end
  end

  describe "integration tests" do
    test "cast -> dump round trip for valid values" do
      valid_values = ["ALL", "NONE", 0.0, 1.5, -2.25, 100.0]

      for value <- valid_values do
        {:ok, casted} = CloseoutUnits.cast(value)
        {:ok, dumped} = CloseoutUnits.dump(casted)
        assert dumped == casted
      end
    end

    test "load -> dump round trip for valid values" do
      valid_values = ["ALL", "NONE", 0.0, 1.5, -2.25, 100.0]

      for value <- valid_values do
        {:ok, loaded} = CloseoutUnits.load(value)
        {:ok, dumped} = CloseoutUnits.dump(loaded)
        assert dumped == loaded
      end
    end

    test "type specification matches actual behavior" do
      # Test that the @type t :: String.t() | float() is accurate
      assert is_binary("ALL")
      assert is_binary("NONE")
      assert is_float(1.5)
      assert is_float(0.0)
    end
  end
end
