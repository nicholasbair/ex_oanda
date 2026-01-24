defmodule ExOanda.Integration.HTTPIntegrationTest do
  @moduledoc """
  Integration tests that verify HTTP requests are constructed correctly for all generated API modules.
  """
  use ExUnit.Case, async: true

  alias ExOanda.Connection

  setup do
    bypass = Bypass.open()

    conn = %Connection{
      token: "test_token",
      api_server: "http://localhost:#{bypass.port}",
      stream_server: "http://localhost:#{bypass.port}",
      options: [retry: false]
    }

    {:ok, bypass: bypass, conn: conn}
  end

  describe "Accounts API" do
    test "list/1 sends GET request with auth header", %{bypass: bypass, conn: conn} do
      Bypass.expect_once(bypass, "GET", "/accounts", fn conn ->
        assert Plug.Conn.get_req_header(conn, "authorization") == ["Bearer test_token"]
        Plug.Conn.resp(conn, 200, ~s({"accounts": []}))
      end)

      ExOanda.Accounts.list(conn)
    end

    test "find/2 sends GET with account_id in path", %{bypass: bypass, conn: conn} do
      Bypass.expect_once(bypass, "GET", "/accounts/123", fn conn ->
        assert Plug.Conn.get_req_header(conn, "authorization") == ["Bearer test_token"]
        Plug.Conn.resp(conn, 200, ~s({"account": {"id": "123"}}))
      end)

      ExOanda.Accounts.find(conn, "123")
    end

    test "update/3 sends PATCH with JSON body", %{bypass: bypass, conn: conn} do
      Bypass.expect_once(bypass, "PATCH", "/accounts/123/configuration", fn conn ->
        {:ok, body, conn} = Plug.Conn.read_body(conn)
        assert Jason.decode!(body)["alias"] == "New Name"
        Plug.Conn.resp(conn, 200, ~s({"clientConfigureTransaction": {}}))
      end)

      ExOanda.Accounts.update(conn, "123", %{alias: "New Name"})
    end
  end

  describe "Orders API" do
    test "create/3 sends POST with order body", %{bypass: bypass, conn: conn} do
      Bypass.expect_once(bypass, "POST", "/accounts/123/orders", fn conn ->
        {:ok, body, conn} = Plug.Conn.read_body(conn)
        parsed = Jason.decode!(body)
        assert parsed["order"]["instrument"] == "EUR_USD"

        Plug.Conn.resp(conn, 201, ~s({"orderCreateTransaction": {"id": "1", "type": "MARKET_ORDER"}, "relatedTransactionIDs": ["1"], "lastTransactionID": "1"}))
      end)

      ExOanda.Orders.create(conn, "123", %{
        order: %{
          type: "MARKET",
          instrument: "EUR_USD",
          units: "100",
          time_in_force: "FOK",
          position_fill: "DEFAULT"
        }
      })
    end

    test "list/2 sends GET with query parameters", %{bypass: bypass, conn: conn} do
      Bypass.expect_once(bypass, "GET", "/accounts/123/orders", fn conn ->
        assert conn.query_params["state"] == "PENDING"
        assert conn.query_params["count"] == "10"
        Plug.Conn.resp(conn, 200, ~s({"orders": []}))
      end)

      ExOanda.Orders.list(conn, "123", state: "PENDING", count: 10)
    end

    test "cancel/3 sends PUT request", %{bypass: bypass, conn: conn} do
      Bypass.expect_once(bypass, "PUT", "/accounts/123/orders/456/cancel", fn conn ->
        Plug.Conn.resp(conn, 200, ~s({"orderCancelTransaction": {}}))
      end)

      ExOanda.Orders.cancel(conn, "123", "456")
    end
  end

  describe "Trades API" do
    test "close/4 sends PUT to close trade", %{bypass: bypass, conn: conn} do
      Bypass.expect_once(bypass, "PUT", "/accounts/123/trades/456/close", fn conn ->
        {:ok, body, conn} = Plug.Conn.read_body(conn)
        assert Jason.decode!(body)["units"] == "ALL"
        Plug.Conn.resp(conn, 200, ~s({"orderCreateTransaction": {}}))
      end)

      ExOanda.Trades.close(conn, "123", "456", %{units: "ALL"})
    end
  end

  describe "Positions API" do
    test "close/4 sends PUT with long_units", %{bypass: bypass, conn: conn} do
      Bypass.expect_once(bypass, "PUT", "/accounts/123/positions/EUR_USD/close", fn conn ->
        {:ok, body, conn} = Plug.Conn.read_body(conn)
        assert Jason.decode!(body)["longUnits"] == "ALL"
        Plug.Conn.resp(conn, 200, ~s({"longOrderCreateTransaction": {}}))
      end)

      ExOanda.Positions.close(conn, "123", "EUR_USD", %{long_units: "ALL"})
    end
  end

  describe "Pricing API" do
    test "list/3 sends GET with instruments parameter", %{bypass: bypass, conn: conn} do
      Bypass.expect_once(bypass, "GET", "/accounts/123/pricing", fn conn ->
        assert conn.query_params["instruments"] == "EUR_USD,GBP_USD"
        Plug.Conn.resp(conn, 200, ~s({"prices": []}))
      end)

      ExOanda.Pricing.list(conn, "123", instruments: "EUR_USD,GBP_USD")
    end
  end

  describe "Instruments API" do
    test "list_candles/2 sends GET with custom params", %{bypass: bypass, conn: conn} do
      Bypass.expect_once(bypass, "GET", "/instruments/EUR_USD/candles", fn conn ->
        assert conn.query_params["granularity"] == "M1"
        assert conn.query_params["count"] == "100"
        Plug.Conn.resp(conn, 200, ~s({"instrument": "EUR_USD", "granularity": "M1", "candles": []}))
      end)

      ExOanda.Instruments.list_candles(conn, "EUR_USD", granularity: "M1", count: 100)
    end
  end

  describe "Transactions API" do
    test "find/3 sends GET to transaction endpoint", %{bypass: bypass, conn: conn} do
      Bypass.expect_once(bypass, "GET", "/accounts/123/transactions/456", fn conn ->
        Plug.Conn.resp(conn, 200, ~s({"transaction": {"id": "456"}}))
      end)

      ExOanda.Transactions.find(conn, "123", "456")
    end
  end
end
