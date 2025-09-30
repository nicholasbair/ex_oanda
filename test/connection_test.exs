defmodule ExOanda.ConnectionTest do
  use ExUnit.Case, async: true

  alias ExOanda.Connection

  describe "struct creation" do
    test "creates struct with required token" do
      conn = %Connection{token: "test-token"}

      assert conn.token == "test-token"
      assert conn.api_server == "https://api-fxpractice.oanda.com/v3"
      assert conn.stream_server == "https://stream-fxpractice.oanda.com/v3"
      assert conn.options == []
      assert conn.telemetry == false
    end

    test "creates struct with custom values" do
      conn = %Connection{
        token: "custom-token",
        api_server: "https://api-fxtrade.oanda.com/v3",
        stream_server: "https://stream-fxtrade.oanda.com/v3",
        options: [timeout: 5000],
        telemetry: true
      }

      assert conn.token == "custom-token"
      assert conn.api_server == "https://api-fxtrade.oanda.com/v3"
      assert conn.stream_server == "https://stream-fxtrade.oanda.com/v3"
      assert conn.options == [timeout: 5000]
      assert conn.telemetry == true
    end
  end

  describe "type specification" do
    test "struct matches the @type t specification" do
      conn = %Connection{token: "test"}

      assert is_binary(conn.token)
      assert is_binary(conn.api_server)
      assert is_binary(conn.stream_server)
      assert is_list(conn.options)
      assert is_boolean(conn.telemetry)
    end
  end
end
