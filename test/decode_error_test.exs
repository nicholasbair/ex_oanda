defmodule ExOanda.DecodeErrorTest do
  use ExUnit.Case, async: true

  alias ExOanda.DecodeError

  describe "exception/1" do
    test "creates exception from Jason.DecodeError with position" do
      jason_error = %Jason.DecodeError{data: "invalid json", position: 5}
      exception = DecodeError.exception(jason_error)

      assert %DecodeError{} = exception
      assert exception.message == "JSON decode error at position 5: \"invalid json\""
      assert exception.reason == :invalid_json
    end

    test "creates exception from Jason.DecodeError without position" do
      jason_error = %Jason.DecodeError{data: "malformed json"}
      exception = DecodeError.exception(jason_error)

      assert %DecodeError{} = exception
      assert exception.message == "JSON decode error: \"malformed json\""
      assert exception.reason == :invalid_json
    end

    test "creates exception from string reason" do
      exception = DecodeError.exception("Invalid JSON format")

      assert %DecodeError{} = exception
      assert exception.message == "JSON decode error: Invalid JSON format"
      assert exception.reason == "Invalid JSON format"
    end

    test "creates exception from atom reason" do
      exception = DecodeError.exception(:malformed_json)

      assert %DecodeError{} = exception
      assert exception.message == "JSON decode error: malformed_json"
      assert exception.reason == :malformed_json
    end

    test "creates exception from other values" do
      exception = DecodeError.exception(%{error: "complex", code: 123})

      assert %DecodeError{} = exception
      assert exception.message =~ "JSON decode error: %{"
      assert exception.message =~ "error: \"complex\""
      assert exception.message =~ "code: 123"
      assert exception.reason == %{error: "complex", code: 123}
    end
  end

  describe "exception behavior" do
    test "DecodeError can be raised and caught" do
      error = %DecodeError{message: "test decode error", reason: :test}

      assert_raise DecodeError, "test decode error", fn ->
        raise error
      end
    end

    test "DecodeError can be raised with custom message" do
      assert_raise DecodeError, "JSON decode error: test", fn ->
        raise DecodeError, "test"
      end
    end
  end

  describe "Jason.DecodeError integration" do
    test "handles Jason.DecodeError with complex data" do
      jason_error = %Jason.DecodeError{
        data: %{invalid: "json", with: "nested", data: [1, 2, 3]},
        position: 42
      }
      exception = DecodeError.exception(jason_error)

      assert %DecodeError{} = exception
      assert exception.message =~ "JSON decode error at position 42:"
      assert exception.message =~ "invalid"
      assert exception.reason == :invalid_json
    end

    test "handles Jason.DecodeError with binary data" do
      jason_error = %Jason.DecodeError{data: <<0, 1, 2, 3>>, position: 0}
      exception = DecodeError.exception(jason_error)

      assert %DecodeError{} = exception
      assert exception.message =~ "JSON decode error at position 0:"
      assert exception.reason == :invalid_json
    end
  end

  describe "edge cases" do
    test "handles nil reason" do
      exception = DecodeError.exception(nil)

      assert %DecodeError{} = exception
      assert exception.message == "JSON decode error: "
      assert exception.reason == nil
    end

    test "handles boolean reason" do
      exception = DecodeError.exception(true)

      assert %DecodeError{} = exception
      assert exception.message == "JSON decode error: true"
      assert exception.reason == true
    end

    test "handles numeric reason" do
      exception = DecodeError.exception(42)

      assert %DecodeError{} = exception
      assert exception.message == "JSON decode error: 42"
      assert exception.reason == 42
    end

    test "handles list reason" do
      exception = DecodeError.exception([1, 2, 3])

      assert %DecodeError{} = exception
      assert exception.message == "JSON decode error: [1, 2, 3]"
      assert exception.reason == [1, 2, 3]
    end
  end

  describe "error message formatting" do
    test "formats Jason.DecodeError with position correctly" do
      jason_error = %Jason.DecodeError{data: "test", position: 10}
      exception = DecodeError.exception(jason_error)

      assert exception.message == "JSON decode error at position 10: \"test\""
    end

    test "formats Jason.DecodeError without position correctly" do
      jason_error = %Jason.DecodeError{data: "test"}
      exception = DecodeError.exception(jason_error)

      assert exception.message == "JSON decode error: \"test\""
    end

    test "formats string reasons correctly" do
      exception = DecodeError.exception("Custom error message")

      assert exception.message == "JSON decode error: Custom error message"
    end

    test "formats atom reasons correctly" do
      exception = DecodeError.exception(:custom_error)

      assert exception.message == "JSON decode error: custom_error"
    end
  end
end
