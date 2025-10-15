defmodule ExOanda.ValidationErrorIntegrationTest do
  use ExUnit.Case, async: true

  alias ExOanda.ValidationError

  describe "ValidationError exception behavior" do
    test "ValidationError can be raised and caught" do
      error = %ValidationError{message: "test error", error: nil, validation_type: :parameter_validation}

      assert_raise ValidationError, "test error", fn ->
        raise error
      end
    end

    test "ValidationError message is properly formatted" do
      nimble_error = %NimbleOptions.ValidationError{key: :test_param, message: "invalid value"}
      error = ValidationError.exception(nimble_error)

      assert error.message == "Parameter validation failed: invalid value"
    end
  end
end
