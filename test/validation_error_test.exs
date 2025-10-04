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
  end
end
