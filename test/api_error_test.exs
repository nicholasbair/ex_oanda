defmodule ExOandaTest.APIError do
  use ExUnit.Case, async: true

  test "ExOanda.APIError includes the correct message" do
    assert_raise ExOanda.APIError, "API Error: \"error message\"", fn ->
      raise ExOanda.APIError, "error message"
    end
  end
end
