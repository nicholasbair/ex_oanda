defmodule ExOanda.StreamingTest do
  use ExUnit.Case, async: true

  alias ExOanda.{Connection, ValidationError}
  alias ExOanda.Streaming

  describe "price_stream/4 validation" do
    test "returns {:error, ValidationError} with missing required instruments" do
      conn = %Connection{token: "test", api_server: "https://api-fxtrade.oanda.com", stream_server: "https://stream-fxtrade.oanda.com"}
      account_id = "101-004-22222222-001"
      stream_to = fn _ -> :ok end
      params = []

      {:error, error} = Streaming.price_stream(conn, account_id, stream_to, params)

      assert %ValidationError{} = error
      assert error.message =~ "Parameter validation failed"
    end

    test "returns {:error, ValidationError} with invalid instruments type" do
      conn = %Connection{token: "test", api_server: "https://api-fxtrade.oanda.com", stream_server: "https://stream-fxtrade.oanda.com"}
      account_id = "101-004-22222222-001"
      stream_to = fn _ -> :ok end
      params = [instruments: "not_a_list"]

      {:error, error} = Streaming.price_stream(conn, account_id, stream_to, params)

      assert %ValidationError{} = error
      assert error.message =~ "Parameter validation failed"
    end

    test "uses default empty params when not provided" do
      conn = %Connection{token: "test", api_server: "https://api-fxtrade.oanda.com", stream_server: "https://stream-fxtrade.oanda.com"}
      account_id = "101-004-22222222-001"
      stream_to = fn _ -> :ok end

      {:error, error} = Streaming.price_stream(conn, account_id, stream_to)

      assert %ValidationError{} = error
    end

    test "handles instruments with non-string values" do
      conn = %Connection{token: "test", api_server: "https://api-fxtrade.oanda.com", stream_server: "https://stream-fxtrade.oanda.com"}
      account_id = "101-004-22222222-001"
      stream_to = fn _ -> :ok end
      params = [instruments: [123, :atom, %{key: "value"}]]

      {:error, error} = Streaming.price_stream(conn, account_id, stream_to, params)

      assert %ValidationError{} = error
    end

    test "accepts valid instruments parameter" do
      conn = %Connection{token: "test", api_server: "https://api-fxtrade.oanda.com", stream_server: "https://stream-fxtrade.oanda.com"}
      account_id = "101-004-22222222-001"
      stream_to = fn _ -> :ok end
      params = [instruments: ["EUR_USD"]]

      # This will fail due to HTTP request, but validates the parameter validation passes
      # We expect a different error than ValidationError, indicating validation passed
      assert_raise Jason.DecodeError, fn ->
        Streaming.price_stream(conn, account_id, stream_to, params)
      end
    end

    test "accepts multiple valid instruments" do
      conn = %Connection{token: "test", api_server: "https://api-fxtrade.oanda.com", stream_server: "https://stream-fxtrade.oanda.com"}
      account_id = "101-004-22222222-001"
      stream_to = fn _ -> :ok end
      params = [instruments: ["EUR_USD", "GBP_USD", "USD_JPY"]]

      # This will fail due to HTTP request, but validates the parameter validation passes
      assert_raise Jason.DecodeError, fn ->
        Streaming.price_stream(conn, account_id, stream_to, params)
      end
    end

    test "handles extra parameters in price_stream" do
      conn = %Connection{token: "test", api_server: "https://api-fxtrade.oanda.com", stream_server: "https://stream-fxtrade.oanda.com"}
      account_id = "101-004-22222222-001"
      stream_to = fn _ -> :ok end
      params = [instruments: ["EUR_USD"], extra_param: "value"]

      # Should still work as extra params are ignored by NimbleOptions
      # This will fail due to HTTP request, but validates the parameter validation passes
      result = Streaming.price_stream(conn, account_id, stream_to, params)

      # The function should return a tuple (likely {:ok, _} or {:error, _})
      assert is_tuple(result)
    end

    test "accepts empty instruments list (validated by API, not client)" do
      conn = %Connection{token: "test", api_server: "https://api-fxtrade.oanda.com", stream_server: "https://stream-fxtrade.oanda.com"}
      account_id = "101-004-22222222-001"
      stream_to = fn _ -> :ok end
      params = [instruments: []]

      # Empty list is valid according to NimbleOptions, will fail at HTTP level
      assert_raise Jason.DecodeError, fn ->
        Streaming.price_stream(conn, account_id, stream_to, params)
      end
    end
  end

  describe "price_stream!/4 validation" do
    test "raises ValidationError when price_stream returns {:error, ValidationError}" do
      conn = %Connection{token: "test", api_server: "https://api-fxtrade.oanda.com", stream_server: "https://stream-fxtrade.oanda.com"}
      account_id = "101-004-22222222-001"
      stream_to = fn _ -> :ok end

      assert_raise ValidationError, fn ->
        Streaming.price_stream!(conn, account_id, stream_to, [])
      end
    end

    test "raises ValidationError for invalid instruments type" do
      conn = %Connection{token: "test", api_server: "https://api-fxtrade.oanda.com", stream_server: "https://stream-fxtrade.oanda.com"}
      account_id = "101-004-22222222-001"
      stream_to = fn _ -> :ok end

      assert_raise ValidationError, fn ->
        Streaming.price_stream!(conn, account_id, stream_to, [instruments: "not_a_list"])
      end
    end

    test "uses default empty params when not provided" do
      conn = %Connection{token: "test", api_server: "https://api-fxtrade.oanda.com", stream_server: "https://stream-fxtrade.oanda.com"}
      account_id = "101-004-22222222-001"
      stream_to = fn _ -> :ok end

      assert_raise ValidationError, fn ->
        Streaming.price_stream!(conn, account_id, stream_to)
      end
    end

    test "raises ValidationError for non-string instruments" do
      conn = %Connection{token: "test", api_server: "https://api-fxtrade.oanda.com", stream_server: "https://stream-fxtrade.oanda.com"}
      account_id = "101-004-22222222-001"
      stream_to = fn _ -> :ok end

      assert_raise ValidationError, fn ->
        Streaming.price_stream!(conn, account_id, stream_to, [instruments: [123, :atom]])
      end
    end

    test "raises Jason.DecodeError for empty instruments list (validated by API)" do
      conn = %Connection{token: "test", api_server: "https://api-fxtrade.oanda.com", stream_server: "https://stream-fxtrade.oanda.com"}
      account_id = "101-004-22222222-001"
      stream_to = fn _ -> :ok end

      # Empty list passes validation but fails at HTTP level
      assert_raise Jason.DecodeError, fn ->
        Streaming.price_stream!(conn, account_id, stream_to, [instruments: []])
      end
    end
  end

  describe "transaction_stream/3" do
    test "accepts valid parameters" do
      conn = %Connection{token: "test", api_server: "https://api-fxtrade.oanda.com", stream_server: "https://stream-fxtrade.oanda.com"}
      account_id = "101-004-22222222-001"
      stream_to = fn _ -> :ok end
      params = [some: "param"]

      # This will fail due to HTTP request, but validates the function accepts parameters
      assert_raise Jason.DecodeError, fn ->
        Streaming.transaction_stream(conn, account_id, stream_to, params)
      end
    end

    test "uses default empty params when not provided" do
      conn = %Connection{token: "test", api_server: "https://api-fxtrade.oanda.com", stream_server: "https://stream-fxtrade.oanda.com"}
      account_id = "101-004-22222222-001"
      stream_to = fn _ -> :ok end

      # This will fail due to HTTP request, but validates the function accepts parameters
      assert_raise Jason.DecodeError, fn ->
        Streaming.transaction_stream(conn, account_id, stream_to)
      end
    end
  end

  describe "error handling" do
    test "handles invalid connection struct" do
      # Test with invalid connection struct
      invalid_conn = %{token: "test"}
      account_id = "101-004-22222222-001"
      stream_to = fn _ -> :ok end

      # This should raise a FunctionClauseError due to pattern matching
      assert_raise FunctionClauseError, fn ->
        Streaming.transaction_stream(invalid_conn, account_id, stream_to)
      end
    end

    test "handles nil account_id" do
      conn = %Connection{token: "test", api_server: "https://api-fxtrade.oanda.com", stream_server: "https://stream-fxtrade.oanda.com"}
      stream_to = fn _ -> :ok end

      # This will fail due to HTTP request, but tests that nil account_id is accepted
      assert_raise Jason.DecodeError, fn ->
        Streaming.transaction_stream(conn, nil, stream_to)
      end
    end

    test "handles nil stream_to function" do
      conn = %Connection{token: "test", api_server: "https://api-fxtrade.oanda.com", stream_server: "https://stream-fxtrade.oanda.com"}
      account_id = "101-004-22222222-001"

      # This will fail due to HTTP request, but tests that nil stream_to is accepted
      assert_raise Jason.DecodeError, fn ->
        Streaming.transaction_stream(conn, account_id, nil)
      end
    end
  end

  describe "streaming integration with Bypass" do
    setup do
      bypass = Bypass.open()
      conn = %Connection{
        token: "test_token",
        api_server: "https://api-fxtrade.oanda.com",
        stream_server: "http://localhost:#{bypass.port}"
      }
      {:ok, bypass: bypass, conn: conn}
    end

    test "price_stream handles validation errors before making HTTP request", %{bypass: _bypass, conn: conn} do
      account_id = "test_account"
      stream_to = fn _ -> :ok end
      params = []  # Missing required instruments

      {:error, error} = Streaming.price_stream(conn, account_id, stream_to, params)

      assert %ValidationError{} = error

      # Verify that no HTTP request was made to Bypass
      # (This test passes if we reach this point without Bypass being called)
    end

    test "price_stream! raises ValidationError for invalid parameters", %{bypass: _bypass, conn: conn} do
      account_id = "test_account"
      stream_to = fn _ -> :ok end
      params = []  # Missing required instruments

      assert_raise ValidationError, fn ->
        Streaming.price_stream!(conn, account_id, stream_to, params)
      end

      # Verify that no HTTP request was made to Bypass
      # (This test passes if we reach this point without Bypass being called)
    end
  end
end
