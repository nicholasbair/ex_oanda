defmodule ExOanda.ValidationErrorTest do
  use ExUnit.Case, async: true

  alias ExOanda.ValidationError

  describe "exception/1" do
    test "creates exception from NimbleOptions.ValidationError struct" do
      nimble_error = %NimbleOptions.ValidationError{
        key: :invalid_param,
        message: "invalid value"
      }

      exception = ValidationError.exception(nimble_error)

      assert %ValidationError{} = exception
      assert exception.message == "Parameter validation failed: invalid value"
      assert exception.errors == [nimble_error]
    end

    test "creates exception from list of NimbleOptions.ValidationError structs" do
      nimble_errors = [
        %NimbleOptions.ValidationError{key: :param1, message: "required"},
        %NimbleOptions.ValidationError{key: :param2, message: "invalid type"}
      ]

      exception = ValidationError.exception(nimble_errors)

      assert %ValidationError{} = exception
      assert exception.message == "Parameter validation failed: param1: required, param2: invalid type"
      assert exception.errors == nimble_errors
    end

    test "handles empty list of errors" do
      exception = ValidationError.exception([])

      assert %ValidationError{} = exception
      assert exception.message == "Parameter validation failed: "
      assert exception.errors == []
    end
  end

  describe "format_errors/1" do
    test "formats multiple errors correctly" do
      errors = [
        %NimbleOptions.ValidationError{key: :name, message: "can't be blank"},
        %NimbleOptions.ValidationError{key: :age, message: "must be a number"}
      ]

      formatted = ValidationError.exception(errors).message

      assert formatted =~ "name: can't be blank"
      assert formatted =~ "age: must be a number"
    end
  end
end
