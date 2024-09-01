defmodule ExOandaTest.Error do
  use ExUnit.Case, async: true

  test "ExOanda.Error includes the correct message" do
    assert_raise ExOandaError, "Error: \"error message\"", fn ->
      raise ExOandaError, "error message"
    end
  end
end
