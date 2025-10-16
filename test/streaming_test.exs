defmodule ExOanda.StreamingTest do
  use ExUnit.Case, async: true

  alias ExOanda.{Connection, ValidationError}
  alias ExOanda.Streaming

  setup do
    bypass = Bypass.open()
    conn = %Connection{
      token: "test_token",
      api_server: "https://api-fxtrade.oanda.com",
      stream_server: "http://localhost:#{bypass.port}",
      options: [retry: false]
    }
    {:ok, bypass: bypass, conn: conn}
  end

  describe "price_stream/4 validation" do
    test "returns {:error, ValidationError} with missing required instruments", %{conn: conn} do
      account_id = "101-004-22222222-001"
      stream_to = fn _ -> :ok end
      params = [foo: ["bar"]]

      {:error, error} = Streaming.price_stream(conn, account_id, stream_to, params)

      assert %ValidationError{} = error
      assert error.message =~ "Parameter validation failed"
    end

    test "returns {:error, ValidationError} with invalid instruments type", %{conn: conn} do
      account_id = "101-004-22222222-001"
      stream_to = fn _ -> :ok end
      params = [instruments: "not_a_list"]

      {:error, error} = Streaming.price_stream(conn, account_id, stream_to, params)

      assert %ValidationError{} = error
      assert error.message =~ "Parameter validation failed"
    end

    test "uses default empty params when not provided", %{conn: conn} do
      account_id = "101-004-22222222-001"
      stream_to = fn _ -> :ok end

      {:error, error} = Streaming.price_stream(conn, account_id, stream_to)

      assert %ValidationError{} = error
      assert error.message =~ "Parameter validation failed"
    end

    test "handles instruments with non-string values", %{conn: conn} do
      account_id = "101-004-22222222-001"
      stream_to = fn _ -> :ok end
      params = [instruments: [123, :atom, %{key: "value"}]]

      {:error, error} = Streaming.price_stream(conn, account_id, stream_to, params)

      assert %ValidationError{} = error
      assert error.message =~ "Parameter validation failed"
    end

    test "accepts valid instruments parameter", %{bypass: bypass, conn: conn} do
      account_id = "101-004-22222222-001"
      stream_to = fn _ -> :ok end
      params = [instruments: ["EUR_USD"]]

      Bypass.expect(bypass, fn conn ->
        assert conn.request_path == "/accounts/#{account_id}/pricing/stream"
        assert conn.query_params == %{"instruments" => "EUR_USD"}

        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.send_resp(200, "{\"type\":\"HEARTBEAT\",\"time\":\"2023-01-01T00:00:00.000000000Z\"}")
      end)

      result = Streaming.price_stream(conn, account_id, stream_to, params)

      assert {:ok, %Req.Response{}} = result
    end

    test "accepts multiple valid instruments", %{bypass: bypass, conn: conn} do
      account_id = "101-004-22222222-001"
      stream_to = fn _ -> :ok end
      params = [instruments: ["EUR_USD", "GBP_USD", "USD_JPY"]]

      Bypass.expect(bypass, fn conn ->
        assert conn.request_path == "/accounts/#{account_id}/pricing/stream"
        assert conn.query_params == %{"instruments" => "EUR_USD,GBP_USD,USD_JPY"}

        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.send_resp(200, "{\"type\":\"HEARTBEAT\",\"time\":\"2023-01-01T00:00:00.000000000Z\"}")
      end)

      result = Streaming.price_stream(conn, account_id, stream_to, params)

      assert {:ok, %Req.Response{}} = result
    end

    test "handles extra parameters in price_stream" do
      conn = %Connection{token: "test", api_server: "https://api-fxtrade.oanda.com", stream_server: "https://stream-fxtrade.oanda.com"}
      account_id = "101-004-22222222-001"
      stream_to = fn _ -> :ok end
      params = [instruments: ["EUR_USD"], extra_param: "value"]

      result = Streaming.price_stream(conn, account_id, stream_to, params)

      assert is_tuple(result)
    end
  end

  describe "price_stream!/4 validation" do
    test "raises ValidationError when instruments parameter is missing", %{conn: conn} do
      account_id = "101-004-22222222-001"
      stream_to = fn _ -> :ok end

      assert_raise ExOanda.ValidationError, fn ->
        Streaming.price_stream!(conn, account_id, stream_to, [])
      end
    end

    test "raises ValidationError for invalid instruments type", %{conn: conn} do
      account_id = "101-004-22222222-001"
      stream_to = fn _ -> :ok end
      params = [instruments: "not_a_list"]

      assert_raise ExOanda.ValidationError, fn ->
        Streaming.price_stream!(conn, account_id, stream_to, params)
      end
    end

    test "raises ValidationError when no params provided", %{conn: conn} do
      account_id = "101-004-22222222-001"
      stream_to = fn _ -> :ok end

      assert_raise ExOanda.ValidationError, fn ->
        Streaming.price_stream!(conn, account_id, stream_to)
      end
    end

    test "raises ValidationError for non-string instruments", %{conn: conn} do
      account_id = "101-004-22222222-001"
      stream_to = fn _ -> :ok end
      params = [instruments: [123, :atom]]

      assert_raise ExOanda.ValidationError, fn ->
        Streaming.price_stream!(conn, account_id, stream_to, params)
      end
    end
  end

  describe "transaction_stream/3" do
    test "accepts valid parameters", %{bypass: bypass, conn: conn} do
      account_id = "101-004-22222222-001"
      stream_to = fn _ -> :ok end
      params = [some: "param"]

      Bypass.expect(bypass, fn conn ->
        assert conn.request_path == "/accounts/#{account_id}/transactions/stream"

        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.send_resp(200, "{\"type\":\"ORDER_FILL\",\"id\":\"123\",\"time\":\"2023-01-01T00:00:00.000000000Z\"}")
      end)

      result = Streaming.transaction_stream(conn, account_id, stream_to, params)

      assert {:ok, %Req.Response{}} = result
    end

    test "uses default empty params when not provided", %{bypass: bypass, conn: conn} do
      account_id = "101-004-22222222-001"
      stream_to = fn _ -> :ok end

      Bypass.expect(bypass, fn conn ->
        assert conn.request_path == "/accounts/#{account_id}/transactions/stream"

        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.send_resp(200, "{\"type\":\"ORDER_FILL\",\"id\":\"123\",\"time\":\"2023-01-01T00:00:00.000000000Z\"}")
      end)

      result = Streaming.transaction_stream(conn, account_id, stream_to)

      assert {:ok, %Req.Response{}} = result
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

    test "handles nil account_id", %{bypass: bypass, conn: conn} do
      stream_to = fn _ -> :ok end

      Bypass.expect(bypass, fn conn ->
        assert conn.request_path == "/accounts//transactions/stream"

        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.send_resp(200, "{\"type\":\"ORDER_FILL\",\"id\":\"123\",\"time\":\"2023-01-01T00:00:00.000000000Z\"}")
      end)

      result = Streaming.transaction_stream(conn, nil, stream_to)

      assert {:ok, %Req.Response{}} = result
    end

    test "handles nil stream_to function", %{bypass: bypass, conn: conn} do
      account_id = "101-004-22222222-001"

      Bypass.expect(bypass, fn conn ->
        assert conn.request_path == "/accounts/#{account_id}/transactions/stream"

        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.send_resp(200, "{\"type\":\"ORDER_FILL\",\"id\":\"123\",\"time\":\"2023-01-01T00:00:00.000000000Z\"}")
      end)

      assert_raise BadFunctionError, fn ->
        Streaming.transaction_stream(conn, account_id, nil)
      end
    end
  end

  describe "transaction_stream!/3" do
    test "raises APIError when transaction_stream returns {:error, APIError}", %{bypass: bypass, conn: conn} do
      account_id = "101-004-22222222-001"
      stream_to = fn _ -> :ok end

      Bypass.expect(bypass, fn conn ->
        assert conn.request_path == "/accounts/#{account_id}/transactions/stream"

        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.send_resp(400, "{\"errorMessage\":\"Bad request\"}")
      end)

      assert_raise ExOanda.APIError, fn ->
        Streaming.transaction_stream!(conn, account_id, stream_to)
      end
    end

    test "raises APIError for other errors", %{bypass: bypass, conn: conn} do
      account_id = "101-004-22222222-001"
      stream_to = fn _ -> :ok end

      Bypass.expect(bypass, fn conn ->
        assert conn.request_path == "/accounts/#{account_id}/transactions/stream"

        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.send_resp(500, "{\"errorMessage\":\"Internal server error\"}")
      end)

      assert_raise ExOanda.APIError, fn ->
        Streaming.transaction_stream!(conn, account_id, stream_to)
      end
    end
  end

  describe "format_instruments/1 private function" do
    test "formats instruments list correctly", %{bypass: bypass, conn: conn} do
      account_id = "101-004-22222222-001"
      stream_to = fn _ -> :ok end
      params = [instruments: ["EUR_USD", "GBP_USD"]]

      Bypass.expect(bypass, fn conn ->
        assert conn.request_path == "/accounts/#{account_id}/pricing/stream"
        assert conn.query_params == %{"instruments" => "EUR_USD,GBP_USD"}

        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.send_resp(200, "{\"type\":\"HEARTBEAT\",\"time\":\"2023-01-01T00:00:00.000000000Z\"}")
      end)

      result = Streaming.price_stream(conn, account_id, stream_to, params)

      assert {:ok, %Req.Response{}} = result
    end

    test "handles single instrument", %{bypass: bypass, conn: conn} do
      account_id = "101-004-22222222-001"
      stream_to = fn _ -> :ok end
      params = [instruments: ["EUR_USD"]]

      Bypass.expect(bypass, fn conn ->
        assert conn.request_path == "/accounts/#{account_id}/pricing/stream"
        assert conn.query_params == %{"instruments" => "EUR_USD"}

        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.send_resp(200, "{\"type\":\"HEARTBEAT\",\"time\":\"2023-01-01T00:00:00.000000000Z\"}")
      end)

      result = Streaming.price_stream(conn, account_id, stream_to, params)

      assert {:ok, %Req.Response{}} = result
    end
  end

  describe "stream/5 private function" do
    test "handles transaction stream type", %{bypass: bypass, conn: conn} do
      account_id = "101-004-22222222-001"
      stream_to = fn _ -> :ok end

      Bypass.expect(bypass, fn conn ->
        assert conn.request_path == "/accounts/#{account_id}/transactions/stream"

        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.send_resp(200, "{\"type\":\"ORDER_FILL\",\"id\":\"123\",\"time\":\"2023-01-01T00:00:00.000000000Z\"}")
      end)

      result = Streaming.transaction_stream(conn, account_id, stream_to)

      assert {:ok, %Req.Response{}} = result
    end

    test "handles pricing stream type", %{bypass: bypass, conn: conn} do
      account_id = "101-004-22222222-001"
      stream_to = fn _ -> :ok end

      Bypass.expect(bypass, fn conn ->
        assert conn.request_path == "/accounts/#{account_id}/pricing/stream"

        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.send_resp(200, "{\"type\":\"HEARTBEAT\",\"time\":\"2023-01-01T00:00:00.000000000Z\"}")
      end)

      result = Streaming.price_stream(conn, account_id, stream_to, [instruments: ["EUR_USD"]])

      assert {:ok, %Req.Response{}} = result
    end

    test "handles connection options", %{bypass: bypass, conn: conn} do
      account_id = "101-004-22222222-001"
      stream_to = fn _ -> :ok end

      Bypass.expect(bypass, fn conn ->
        assert conn.request_path == "/accounts/#{account_id}/transactions/stream"

        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.send_resp(200, "{\"type\":\"ORDER_FILL\",\"id\":\"123\",\"time\":\"2023-01-01T00:00:00.000000000Z\"}")
      end)

      result = Streaming.transaction_stream(conn, account_id, stream_to)

      assert {:ok, %Req.Response{}} = result
    end
  end

  describe "streaming error handling" do
    setup do
      bypass = Bypass.open()
      conn = %Connection{
        token: "test_token",
        api_server: "https://api-fxtrade.oanda.com",
        stream_server: "http://localhost:#{bypass.port}",
        options: [retry: false]
      }
      {:ok, bypass: bypass, conn: conn}
    end

    test "handles 401 unauthorized error with invalid token", %{bypass: bypass, conn: conn} do
      account_id = "test_account"
      stream_to = fn _ -> :ok end
      params = [instruments: ["EUR_USD"]]

      Bypass.expect(bypass, fn conn ->
        assert conn.request_path == "/accounts/#{account_id}/pricing/stream"
        assert conn.query_params == %{"instruments" => "EUR_USD"}

        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.send_resp(401, "{\"errorMessage\":\"Insufficient authorization to perform request.\"}")
      end)

      result = Streaming.price_stream(conn, account_id, stream_to, params)

      assert {:error, %ExOanda.APIError{}} = result
    end

    test "handles 400 bad request error with missing instruments", %{bypass: bypass, conn: conn} do
      account_id = "test_account"
      stream_to = fn _ -> :ok end
      params = [instruments: []]

      Bypass.expect(bypass, fn conn ->
        assert conn.request_path == "/accounts/#{account_id}/pricing/stream"
        assert conn.query_params == %{"instruments" => ""}

        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.send_resp(400, "{\"errorMessage\":\"Missing 'instruments' parameter\",\"errorCode\":\"oanda::rest::core::MissingParameterException\"}")
      end)

      result = Streaming.price_stream(conn, account_id, stream_to, params)

      assert {:error, %ExOanda.APIError{}} = result
    end

    test "handles 401 unauthorized error in transaction stream", %{bypass: bypass, conn: conn} do
      account_id = "test_account"
      stream_to = fn _ -> :ok end

      Bypass.expect(bypass, fn conn ->
        assert conn.request_path == "/accounts/#{account_id}/transactions/stream"

        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.send_resp(401, "{\"errorMessage\":\"Insufficient authorization to perform request.\"}")
      end)

      result = Streaming.transaction_stream(conn, account_id, stream_to)

      assert {:error, %ExOanda.APIError{}} = result
    end

    test "price_stream! raises APIError for 401 unauthorized", %{bypass: bypass, conn: conn} do
      account_id = "test_account"
      stream_to = fn _ -> :ok end
      params = [instruments: ["EUR_USD"]]

      Bypass.expect(bypass, fn conn ->
        assert conn.request_path == "/accounts/#{account_id}/pricing/stream"

        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.send_resp(401, "{\"errorMessage\":\"Insufficient authorization to perform request.\"}")
      end)

      assert_raise ExOanda.APIError, fn ->
        Streaming.price_stream!(conn, account_id, stream_to, params)
      end
    end

    test "transaction_stream! raises APIError for 400 bad request", %{bypass: bypass, conn: conn} do
      account_id = "test_account"
      stream_to = fn _ -> :ok end

      Bypass.expect(bypass, fn conn ->
        assert conn.request_path == "/accounts/#{account_id}/transactions/stream"

        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.send_resp(400, "{\"errorMessage\":\"Missing 'instruments' parameter\",\"errorCode\":\"oanda::rest::core::MissingParameterException\"}")
      end)

      assert_raise ExOanda.APIError, fn ->
        Streaming.transaction_stream!(conn, account_id, stream_to)
      end
    end
  end

  describe "decode error handling in streaming" do
    setup do
      bypass = Bypass.open()
      conn = %Connection{
        token: "test_token",
        api_server: "https://api-fxtrade.oanda.com",
        stream_server: "http://localhost:#{bypass.port}",
        options: [retry: false]
      }
      {:ok, bypass: bypass, conn: conn}
    end

    test "price_stream handles decode errors gracefully", %{bypass: bypass, conn: conn} do
      account_id = "test_account"
      stream_to = fn data ->
        # This function will receive either valid data or DecodeError
        case data do
          %ExOanda.DecodeError{} -> :decode_error_received
          _ -> :valid_data_received
        end
      end
      params = [instruments: ["EUR_USD"]]

      Bypass.expect(bypass, fn conn ->
        assert conn.request_path == "/accounts/#{account_id}/pricing/stream"
        assert conn.query_params == %{"instruments" => "EUR_USD"}

        # Send a mix of valid JSON and invalid JSON
        response = """
        {"type":"HEARTBEAT","time":"2023-01-01T12:00:00.000000000Z"}
        invalid json line
        {"type":"PRICE","instrument":"EUR_USD","time":"2023-01-01T12:00:01.000000000Z"}
        """
        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.send_resp(200, response)
      end)

      {:ok, result} = Streaming.price_stream(conn, account_id, stream_to, params)
      assert %Req.Response{} = result
    end

    test "price_stream! raises decode errors", %{bypass: bypass, conn: conn} do
      account_id = "test_account"
      stream_to = fn _data -> :ok end
      params = [instruments: ["EUR_USD"]]

      Bypass.expect(bypass, fn conn ->
        assert conn.request_path == "/accounts/#{account_id}/pricing/stream"
        assert conn.query_params == %{"instruments" => "EUR_USD"}

        # Send invalid JSON that should cause a decode error
        response = "invalid json line"
        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.send_resp(200, response)
      end)

      assert_raise ExOanda.DecodeError, fn ->
        Streaming.price_stream!(conn, account_id, stream_to, params)
      end
    end

    test "transaction_stream handles decode errors gracefully", %{bypass: bypass, conn: conn} do
      account_id = "test_account"
      stream_to = fn data ->
        # This function will receive either valid data or DecodeError
        case data do
          %ExOanda.DecodeError{} -> :decode_error_received
          _ -> :valid_data_received
        end
      end

      Bypass.expect(bypass, fn conn ->
        assert conn.request_path == "/accounts/#{account_id}/transactions/stream"

        # Send a mix of valid JSON and invalid JSON
        response = """
        {"type":"ORDER_FILL","id":"123","time":"2023-01-01T00:00:00.000000000Z"}
        invalid json line
        {"type":"ORDER_CANCEL","id":"456","time":"2023-01-01T00:00:01.000000000Z"}
        """
        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.send_resp(200, response)
      end)

      {:ok, result} = Streaming.transaction_stream(conn, account_id, stream_to)
      assert %Req.Response{} = result
    end

    test "transaction_stream! raises decode errors", %{bypass: bypass, conn: conn} do
      account_id = "test_account"
      stream_to = fn _data -> :ok end

      Bypass.expect(bypass, fn conn ->
        assert conn.request_path == "/accounts/#{account_id}/transactions/stream"

        # Send invalid JSON that should cause a decode error
        response = "invalid json line"
        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.send_resp(200, response)
      end)

      assert_raise ExOanda.DecodeError, fn ->
        Streaming.transaction_stream!(conn, account_id, stream_to)
      end
    end
  end

  describe "streaming integration with Bypass" do
    setup do
      bypass = Bypass.open()
      conn = %Connection{
        token: "test_token",
        api_server: "https://api-fxtrade.oanda.com",
        stream_server: "http://localhost:#{bypass.port}",
        options: [retry: false]
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

    test "price_stream! works with valid parameters", %{bypass: bypass, conn: conn} do
      account_id = "test_account"
      stream_to = fn _ -> :ok end
      params = [instruments: ["EUR_USD"]]

      Bypass.expect(bypass, fn conn ->
        assert conn.request_path == "/accounts/#{account_id}/pricing/stream"
        assert conn.query_params == %{"instruments" => "EUR_USD"}

        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.send_resp(200, "{\"type\":\"HEARTBEAT\",\"time\":\"2023-01-01T00:00:00.000000000Z\"}")
      end)

      result = Streaming.price_stream!(conn, account_id, stream_to, params)
      assert %Req.Response{} = result
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
