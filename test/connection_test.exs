defmodule ExOanda.ConnectionTest do
  use ExUnit.Case, async: true

  alias ExOanda.{Connection, Telemetry}

  describe "struct creation" do
    test "creates struct with required token" do
      conn = %Connection{token: "test-token"}

      assert conn.token == "test-token"
      assert conn.api_server == "https://api-fxpractice.oanda.com/v3"
      assert conn.stream_server == "https://stream-fxpractice.oanda.com/v3"
      assert conn.options == []
      assert %Telemetry{} = conn.telemetry
      assert conn.telemetry.enabled == false
      assert conn.telemetry.use_default_logger == false
      assert conn.telemetry.options == []
    end

    test "creates struct with custom values" do
      telemetry_config = %Telemetry{
        enabled: true,
        use_default_logger: true,
        options: [pipeline: true, adapter: true]
      }

      conn = %Connection{
        token: "custom-token",
        api_server: "https://api-fxtrade.oanda.com/v3",
        stream_server: "https://stream-fxtrade.oanda.com/v3",
        options: [timeout: 5000],
        telemetry: telemetry_config
      }

      assert conn.token == "custom-token"
      assert conn.api_server == "https://api-fxtrade.oanda.com/v3"
      assert conn.stream_server == "https://stream-fxtrade.oanda.com/v3"
      assert conn.options == [timeout: 5000]
      assert conn.telemetry == telemetry_config
    end

    test "creates struct with enabled telemetry boolean (backward compatibility)" do
      conn = %Connection{
        token: "test-token",
        telemetry: %Telemetry{enabled: true}
      }

      assert conn.telemetry.enabled == true
      assert conn.telemetry.use_default_logger == false
      assert conn.telemetry.options == []
    end
  end

  describe "type specification" do
    test "struct matches the @type t specification" do
      conn = %Connection{token: "test"}

      assert is_binary(conn.token)
      assert is_binary(conn.api_server)
      assert is_binary(conn.stream_server)
      assert is_list(conn.options)
      assert %Telemetry{} = conn.telemetry
    end
  end
end
