defmodule ExOanda.ValidationErrorIntegrationTest do
  use ExUnit.Case, async: true

  alias ExOanda.{Connection, ValidationError}

  describe "streaming validation errors" do
    test "price_stream returns ValidationError for invalid parameters" do
      conn = %Connection{token: "test", api_server: "https://api-fxtrade.oanda.com", stream_server: "https://stream-fxtrade.oanda.com"}

      # Test with invalid parameters (missing required instruments)
      {:error, error} = ExOanda.Streaming.price_stream(conn, "account_id", fn _ -> :ok end, [])

      assert %ValidationError{} = error
      assert error.message =~ "Parameter validation failed"
    end

    test "price_stream! raises ValidationError for invalid parameters" do
      conn = %Connection{token: "test", api_server: "https://api-fxtrade.oanda.com", stream_server: "https://stream-fxtrade.oanda.com"}

      # Test with invalid parameters (missing required instruments)
      assert_raise ValidationError, fn ->
        ExOanda.Streaming.price_stream!(conn, "account_id", fn _ -> :ok end, [])
      end
    end
  end

  describe "ValidationError exception behavior" do
    test "ValidationError can be raised and caught" do
      error = %ValidationError{message: "test error", errors: []}

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
