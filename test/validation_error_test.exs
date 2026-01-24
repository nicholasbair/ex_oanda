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
      assert exception.error == nimble_error
      assert exception.validation_type == :parameter_validation
    end
  end

  describe "exception/1 with Ecto.Changeset" do
    test "creates exception from Ecto.Changeset struct" do
      changeset = %Ecto.Changeset{
        valid?: false,
        errors: [
          name: {"can't be blank", [validation: :required]},
          age: {"must be greater than 0", [validation: :number, kind: :greater_than, number: 0]}
        ],
        data: %{},
        changes: %{name: "", age: -1}
      }

      exception = ValidationError.exception(changeset)

      assert %ValidationError{} = exception
      assert exception.message =~ "Request body validation failed"
      assert exception.message =~ "name: \"can't be blank\""
      assert exception.message =~ "age: \"must be greater than 0\""
      assert exception.error == changeset
      assert exception.validation_type == :request_body_validation
    end

    test "handles changeset with no errors" do
      changeset = %Ecto.Changeset{
        valid?: true,
        errors: [],
        data: %{},
        changes: %{}
      }

      exception = ValidationError.exception(changeset)

      assert %ValidationError{} = exception
      assert exception.message =~ "Request body validation failed"
      assert exception.error == changeset
      assert exception.validation_type == :request_body_validation
    end

    test "handles changeset with embedded schema errors" do
      changeset = %Ecto.Changeset{
        valid?: false,
        errors: [
          order: [
            {:instrument, ["can't be blank"]},
            {:units, ["must be greater than 0"]}
          ]
        ],
        data: %{},
        changes: %{}
      }

      exception = ValidationError.exception(changeset)

      assert %ValidationError{} = exception
      assert exception.message =~ "Request body validation failed"
      assert exception.message =~ "order: [instrument: [\"can't be blank\"], units: [\"must be greater than 0\"]]"
      assert exception.error == changeset
      assert exception.validation_type == :request_body_validation
    end

    test "handles changeset with tuple errors with message and opts" do
      changeset = %Ecto.Changeset{
        valid?: false,
        errors: [
          price: {"must be less than %{max}", [max: 100]}
        ],
        data: %{},
        changes: %{price: 150}
      }

      exception = ValidationError.exception(changeset)

      assert %ValidationError{} = exception
      assert exception.message =~ "Request body validation failed"
      assert exception.message =~ "price: \"must be less than 100\""
      assert exception.error == changeset
      assert exception.validation_type == :request_body_validation
    end

    test "handles changeset with list of embedded errors with atom keys" do
      changeset = %Ecto.Changeset{
        valid?: false,
        errors: [
          order: [
            {:price, ["must be positive"]},
            {:units, ["is required"]}
          ]
        ],
        data: %{},
        changes: %{}
      }

      exception = ValidationError.exception(changeset)

      assert %ValidationError{} = exception
      assert exception.message =~ "Request body validation failed"
      assert exception.message =~ "order:"
      assert exception.message =~ "price: [\"must be positive\"]"
      assert exception.message =~ "units: [\"is required\"]"
      assert exception.error == changeset
      assert exception.validation_type == :request_body_validation
    end

    test "formats multiple errors correctly" do
      changeset = %Ecto.Changeset{
        valid?: false,
        errors: [
          name: {"can't be blank", [validation: :required]},
          email: {"is invalid", [validation: :format]},
          age: {"must be greater than %{number}", [number: 0]}
        ],
        data: %{},
        changes: %{}
      }

      exception = ValidationError.exception(changeset)

      assert %ValidationError{} = exception
      assert exception.message =~ "name: \"can't be blank\""
      assert exception.message =~ "email: \"is invalid\""
      assert exception.message =~ "age: \"must be greater than 0\""
      assert exception.error == changeset
      assert exception.validation_type == :request_body_validation
    end
  end

  describe "exception behavior" do
    test "ValidationError can be raised and caught" do
      nimble_error = %NimbleOptions.ValidationError{
        key: :test,
        message: "test error"
      }

      error = ValidationError.exception(nimble_error)

      assert_raise ValidationError, ~r/Parameter validation failed/, fn ->
        raise error
      end
    end
  end

  describe "edge cases in error formatting" do
    test "handles changeset with deeply nested embedded errors" do
      changeset = %Ecto.Changeset{
        valid?: false,
        errors: [
          items: [
            [
              {:price, ["must be positive"]},
              {:quantity, ["must be greater than 0"]}
            ]
          ]
        ],
        data: %{},
        changes: %{}
      }

      exception = ValidationError.exception(changeset)

      assert %ValidationError{} = exception
      assert exception.message =~ "Request body validation failed"
      assert exception.message =~ "items:"
      assert exception.error == changeset
      assert exception.validation_type == :request_body_validation
    end

    test "handles changeset with interpolated error messages" do
      changeset = %Ecto.Changeset{
        valid?: false,
        errors: [
          count: {"must be between %{min} and %{max}", [min: 1, max: 100]},
          size: {"should be at least %{count} character(s)", [count: 3]}
        ],
        data: %{},
        changes: %{}
      }

      exception = ValidationError.exception(changeset)

      assert %ValidationError{} = exception
      assert exception.message =~ "must be between 1 and 100"
      assert exception.message =~ "should be at least 3 character(s)"
      assert exception.error == changeset
      assert exception.validation_type == :request_body_validation
    end

    test "handles changeset with keyword list errors from embedded schemas" do
      # This simulates errors from cast_embed when there are nested validation errors
      changeset = %Ecto.Changeset{
        valid?: false,
        errors: [
          address: [
            street: ["can't be blank"],
            city: ["can't be blank"]
          ]
        ],
        data: %{},
        changes: %{}
      }

      exception = ValidationError.exception(changeset)

      assert %ValidationError{} = exception
      assert exception.message =~ "Request body validation failed"
      assert exception.message =~ "address:"
      assert exception.error == changeset
      assert exception.validation_type == :request_body_validation
    end

    test "handles changeset with mixed error types" do
      changeset = %Ecto.Changeset{
        valid?: false,
        errors: [
          simple_field: {"can't be blank", [validation: :required]},
          nested_field: [
            sub_field: ["must be positive"]
          ],
          another_field: {"must be unique", []}
        ],
        data: %{},
        changes: %{}
      }

      exception = ValidationError.exception(changeset)

      assert %ValidationError{} = exception
      assert exception.message =~ "Request body validation failed"
      assert exception.message =~ "simple_field:"
      assert exception.message =~ "nested_field:"
      assert exception.message =~ "another_field:"
      assert exception.error == changeset
      assert exception.validation_type == :request_body_validation
    end
  end
end
