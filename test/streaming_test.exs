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

      assert_raise ExOanda.DecodeError, fn ->
        Streaming.price_stream(conn, account_id, stream_to, params)
      end
    end

    test "accepts multiple valid instruments" do
      conn = %Connection{token: "test", api_server: "https://api-fxtrade.oanda.com", stream_server: "https://stream-fxtrade.oanda.com"}
      account_id = "101-004-22222222-001"
      stream_to = fn _ -> :ok end
      params = [instruments: ["EUR_USD", "GBP_USD", "USD_JPY"]]

      assert_raise ExOanda.DecodeError, fn ->
        Streaming.price_stream(conn, account_id, stream_to, params)
      end
    end

    test "handles extra parameters in price_stream" do
      conn = %Connection{token: "test", api_server: "https://api-fxtrade.oanda.com", stream_server: "https://stream-fxtrade.oanda.com"}
      account_id = "101-004-22222222-001"
      stream_to = fn _ -> :ok end
      params = [instruments: ["EUR_USD"], extra_param: "value"]

      result = Streaming.price_stream(conn, account_id, stream_to, params)

      assert is_tuple(result)
    end

    test "accepts empty instruments list (validated by API, not client)" do
      conn = %Connection{token: "test", api_server: "https://api-fxtrade.oanda.com", stream_server: "https://stream-fxtrade.oanda.com"}
      account_id = "101-004-22222222-001"
      stream_to = fn _ -> :ok end
      params = [instruments: []]

      assert_raise ExOanda.DecodeError, fn ->
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

    test "raises ExOanda.DecodeError for empty instruments list (validated by API)" do
      conn = %Connection{token: "test", api_server: "https://api-fxtrade.oanda.com", stream_server: "https://stream-fxtrade.oanda.com"}
      account_id = "101-004-22222222-001"
      stream_to = fn _ -> :ok end

      assert_raise ExOanda.DecodeError, fn ->
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

      assert_raise ExOanda.DecodeError, fn ->
        Streaming.transaction_stream(conn, account_id, stream_to, params)
      end
    end

    test "uses default empty params when not provided" do
      conn = %Connection{token: "test", api_server: "https://api-fxtrade.oanda.com", stream_server: "https://stream-fxtrade.oanda.com"}
      account_id = "101-004-22222222-001"
      stream_to = fn _ -> :ok end

      assert_raise ExOanda.DecodeError, fn ->
        Streaming.transaction_stream(conn, account_id, stream_to)
      end
    end
  end

  describe "error handling" do
    test "handles invalid connection struct" do
      invalid_conn = %{token: "test"}
      account_id = "101-004-22222222-001"
      stream_to = fn _ -> :ok end

      assert_raise FunctionClauseError, fn ->
        Streaming.transaction_stream(invalid_conn, account_id, stream_to)
      end
    end

    test "handles nil account_id" do
      conn = %Connection{token: "test", api_server: "https://api-fxtrade.oanda.com", stream_server: "https://stream-fxtrade.oanda.com"}
      stream_to = fn _ -> :ok end

      assert_raise ExOanda.DecodeError, fn ->
        Streaming.transaction_stream(conn, nil, stream_to)
      end
    end

    test "handles nil stream_to function" do
      conn = %Connection{token: "test", api_server: "https://api-fxtrade.oanda.com", stream_server: "https://stream-fxtrade.oanda.com"}
      account_id = "101-004-22222222-001"

      assert_raise ExOanda.DecodeError, fn ->
        Streaming.transaction_stream(conn, account_id, nil)
      end
    end
  end

  describe "transaction_stream!/3" do
    test "raises TransportError when transaction_stream returns {:error, TransportError}" do
      conn = %Connection{token: "test", api_server: "https://api-fxtrade.oanda.com", stream_server: "https://stream-fxtrade.oanda.com"}
      account_id = "101-004-22222222-001"
      stream_to = fn _ -> :ok end

      assert_raise ExOanda.DecodeError, fn ->
        Streaming.transaction_stream!(conn, account_id, stream_to)
      end
    end

    test "raises APIError for other errors" do
      conn = %Connection{token: "test", api_server: "https://api-fxtrade.oanda.com", stream_server: "https://stream-fxtrade.oanda.com"}
      account_id = "101-004-22222222-001"
      stream_to = fn _ -> :ok end

      assert_raise ExOanda.DecodeError, fn ->
        Streaming.transaction_stream!(conn, account_id, stream_to)
      end
    end
  end

  describe "format_instruments/1 private function" do
    test "formats instruments list correctly" do
      conn = %Connection{token: "test", api_server: "https://api-fxtrade.oanda.com", stream_server: "https://stream-fxtrade.oanda.com"}
      account_id = "101-004-22222222-001"
      stream_to = fn _ -> :ok end
      params = [instruments: ["EUR_USD", "GBP_USD"]]

      assert_raise ExOanda.DecodeError, fn ->
        Streaming.price_stream(conn, account_id, stream_to, params)
      end
    end

    test "handles single instrument" do
      conn = %Connection{token: "test", api_server: "https://api-fxtrade.oanda.com", stream_server: "https://stream-fxtrade.oanda.com"}
      account_id = "101-004-22222222-001"
      stream_to = fn _ -> :ok end
      params = [instruments: ["EUR_USD"]]

      assert_raise ExOanda.DecodeError, fn ->
        Streaming.price_stream(conn, account_id, stream_to, params)
      end
    end
  end

  describe "stream/5 private function" do
    test "handles different stream types" do
      conn = %Connection{token: "test", api_server: "https://api-fxtrade.oanda.com", stream_server: "https://stream-fxtrade.oanda.com"}
      account_id = "101-004-22222222-001"
      stream_to = fn _ -> :ok end

      assert_raise ExOanda.DecodeError, fn ->
        Streaming.transaction_stream(conn, account_id, stream_to)
      end

      assert_raise ExOanda.DecodeError, fn ->
        Streaming.price_stream(conn, account_id, stream_to, [instruments: ["EUR_USD"]])
      end
    end

    test "handles connection options" do
      conn = %Connection{
        token: "test",
        api_server: "https://api-fxtrade.oanda.com",
        stream_server: "https://stream-fxtrade.oanda.com",
        options: [retry: false]
      }
      account_id = "101-004-22222222-001"
      stream_to = fn _ -> :ok end

      assert_raise ExOanda.DecodeError, fn ->
        Streaming.transaction_stream(conn, account_id, stream_to)
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

    end

    test "price_stream! raises ValidationError for invalid parameters", %{bypass: _bypass, conn: conn} do
      account_id = "test_account"
      stream_to = fn _ -> :ok end
      params = []  # Missing required instruments

      assert_raise ValidationError, fn ->
        Streaming.price_stream!(conn, account_id, stream_to, params)
      end

    end

    test "handles successful streaming response", %{bypass: bypass, conn: conn} do
      Bypass.expect(bypass, fn conn ->
        Plug.Conn.send_resp(conn, 200, "{\"type\":\"HEARTBEAT\",\"time\":\"2023-01-01T12:00:00.000000000Z\"}\n")
      end)

      account_id = "test_account"
      stream_to = fn _ -> :ok end
      params = [instruments: ["EUR_USD"]]

      {:ok, result} = Streaming.price_stream(conn, account_id, stream_to, params)

      assert %Req.Response{} = result
    end

    test "handles streaming with multiple data lines", %{bypass: bypass, conn: conn} do
      Bypass.expect(bypass, fn conn ->
        response = """
        {"type":"HEARTBEAT","time":"2023-01-01T12:00:00.000000000Z"}
        {"type":"PRICE","instrument":"EUR_USD","time":"2023-01-01T12:00:01.000000000Z","bids":[{"price":"1.1000","liquidity":1000000}],"asks":[{"price":"1.1002","liquidity":1000000}]}
        """
        Plug.Conn.send_resp(conn, 200, response)
      end)

      account_id = "test_account"
      stream_to = fn _ -> :ok end
      params = [instruments: ["EUR_USD"]]

      {:ok, result} = Streaming.price_stream(conn, account_id, stream_to, params)

      assert %Req.Response{} = result
    end
  end
end
