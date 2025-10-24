defmodule ExOanda.TelemetryTest do
  use ExUnit.Case, async: true
  import ExUnit.CaptureLog

  alias ExOanda.{
    Connection,
    Telemetry
  }

  describe "struct creation" do
    test "creates struct with default values" do
      telemetry = %Telemetry{}

      assert telemetry.enabled == false
      assert telemetry.use_default_logger == false
      assert telemetry.options == []
    end

    test "creates struct with custom values" do
      telemetry = %Telemetry{
        enabled: true,
        use_default_logger: true,
        options: [pipeline: true, adapter: false, metadata: %{api_version: "v3"}]
      }

      assert telemetry.enabled == true
      assert telemetry.use_default_logger == true
      assert telemetry.options == [pipeline: true, adapter: false, metadata: %{api_version: "v3"}]
    end
  end

  describe "maybe_attach_telemetry/2" do
    test "attaches telemetry when enabled is true" do
      ref = :telemetry_test.attach_event_handlers(self(), [
        [:req, :request, :pipeline, :start],
        [:req, :request, :pipeline, :stop]
      ])

      req = Req.new(url: "https://example.com")
      conn = %Connection{
        token: "test-token",
        telemetry: %Telemetry{enabled: true, use_default_logger: false, options: []}
      }

      result = Telemetry.maybe_attach_telemetry(req, conn)

      assert %Req.Request{} = result
      assert result != req, "Request should be modified when telemetry is attached"

      bypass = Bypass.open()
      Bypass.expect(bypass, "GET", "/", fn conn ->
        Plug.Conn.send_resp(conn, 200, "OK")
      end)

      Req.get(result, url: "http://localhost:#{bypass.port}")

      assert_receive {[:req, :request, :pipeline, :start], ^ref, _measurements, _metadata}
      assert_receive {[:req, :request, :pipeline, :stop], ^ref, _measurements, _metadata}

      :telemetry.detach(ref)
    end

    test "attaches telemetry with default logger when use_default_logger is true" do
      ref = :telemetry_test.attach_event_handlers(self(), [
        [:req, :request, :pipeline, :start],
        [:req, :request, :pipeline, :stop]
      ])

      req = Req.new(url: "https://example.com")
      conn = %Connection{
        token: "test-token",
        telemetry: %Telemetry{
          enabled: true,
          use_default_logger: true,
          options: []
        }
      }

      result = Telemetry.maybe_attach_telemetry(req, conn)

      assert %Req.Request{} = result
      assert result != req, "Request should be modified when telemetry is attached"

      bypass = Bypass.open()
      Bypass.expect(bypass, "GET", "/", fn conn ->
        Plug.Conn.send_resp(conn, 200, "OK")
      end)

      log_output = capture_log(fn ->
        Req.get(result, url: "http://localhost:#{bypass.port}")
      end)

      assert log_output =~ "Req:"
      assert log_output =~ "GET"
      assert log_output =~ "http://localhost:#{bypass.port}"
      assert log_output =~ "(pipeline)"
      assert log_output =~ "200"

      assert_receive {[:req, :request, :pipeline, :start], ^ref, _measurements, _metadata}
      assert_receive {[:req, :request, :pipeline, :stop], ^ref, _measurements, _metadata}

      :telemetry.detach(ref)
    end

    test "returns request unchanged when telemetry is disabled" do
      req = Req.new(url: "https://example.com")
      conn = %Connection{
        token: "test-token",
        telemetry: %Telemetry{enabled: false}
      }

      result = Telemetry.maybe_attach_telemetry(req, conn)

      assert result == req
    end

    test "returns request unchanged when telemetry field is missing" do
      req = Req.new(url: "https://example.com")
      conn = %Connection{token: "test-token"}

      result = Telemetry.maybe_attach_telemetry(req, conn)

      assert result == req
    end

    test "returns request unchanged when connection has no telemetry key" do
      req = Req.new(url: "https://example.com")
      conn = %{token: "test-token", other_field: "value"}

      result = Telemetry.maybe_attach_telemetry(req, conn)

      assert result == req
    end

    test "attaches telemetry with custom options" do
      ref = :telemetry_test.attach_event_handlers(self(), [
        [:req, :request, :adapter, :start],
        [:req, :request, :adapter, :stop]
      ])

      req = Req.new(url: "https://example.com")
      custom_options = [
        pipeline: false,
        adapter: true,
        metadata: %{api_version: "v3", endpoint: "accounts"}
      ]

      conn = %Connection{
        token: "test-token",
        telemetry: %Telemetry{
          enabled: true,
          use_default_logger: false,
          options: custom_options
        }
      }

      result = Telemetry.maybe_attach_telemetry(req, conn)

      assert %Req.Request{} = result
      assert result != req, "Request should be modified when telemetry is attached"

      bypass = Bypass.open()
      Bypass.expect(bypass, "GET", "/", fn conn ->
        Plug.Conn.send_resp(conn, 200, "OK")
      end)

      Req.get(result, url: "http://localhost:#{bypass.port}")

      assert_receive {[:req, :request, :adapter, :start], ^ref, _measurements, _metadata}
      assert_receive {[:req, :request, :adapter, :stop], ^ref, _measurements, _metadata}

      :telemetry.detach(ref)
    end

    test "attaches telemetry with boolean true options" do
      ref = :telemetry_test.attach_event_handlers(self(), [
        [:req, :request, :pipeline, :start],
        [:req, :request, :pipeline, :stop]
      ])

      req = Req.new(url: "https://example.com")
      conn = %Connection{
        token: "test-token",
        telemetry: %Telemetry{enabled: true, options: true}
      }

      result = Telemetry.maybe_attach_telemetry(req, conn)

      assert %Req.Request{} = result
      assert result != req, "Request should be modified when telemetry is attached"

      bypass = Bypass.open()
      Bypass.expect(bypass, "GET", "/", fn conn ->
        Plug.Conn.send_resp(conn, 200, "OK")
      end)

      Req.get(result, url: "http://localhost:#{bypass.port}")

      assert_receive {[:req, :request, :pipeline, :start], ^ref, _measurements, _metadata}
      assert_receive {[:req, :request, :pipeline, :stop], ^ref, _measurements, _metadata}

      :telemetry.detach(ref)
    end

    test "attaches telemetry with boolean false options" do
      req = Req.new(url: "https://example.com")
      conn = %Connection{
        token: "test-token",
        telemetry: %Telemetry{enabled: true, options: false}
      }

      result = Telemetry.maybe_attach_telemetry(req, conn)

      assert %Req.Request{} = result
      assert result != req, "Request should be modified when telemetry is attached"

      bypass = Bypass.open()
      Bypass.expect(bypass, "GET", "/", fn conn ->
        Plug.Conn.send_resp(conn, 200, "OK")
      end)

      {:ok, response} = Req.get(result, url: "http://localhost:#{bypass.port}")
      assert response.status == 200
    end
  end

  describe "type specifications" do
    test "struct matches the @type t specification" do
      telemetry = %Telemetry{}

      assert is_boolean(telemetry.enabled)
      assert is_boolean(telemetry.use_default_logger)
      assert is_list(telemetry.options)
    end

    test "options type accepts boolean or list of options" do
      telemetry1 = %Telemetry{options: true}
      assert telemetry1.options == true

      telemetry2 = %Telemetry{options: false}
      assert telemetry2.options == false

      options = [
        {:adapter, true},
        {:pipeline, false},
        {:metadata, %{test: "value"}}
      ]

      telemetry3 = %Telemetry{options: options}
      assert telemetry3.options == options
    end
  end

  describe "integration with API module" do
    test "API.maybe_attach_telemetry delegates to Telemetry.maybe_attach_telemetry" do
      ref = :telemetry_test.attach_event_handlers(self(), [
        [:req, :request, :pipeline, :start],
        [:req, :request, :pipeline, :stop]
      ])

      req = Req.new(url: "https://example.com")
      conn = %Connection{
        token: "test-token",
        telemetry: %Telemetry{enabled: true, options: []}
      }

      result = ExOanda.API.maybe_attach_telemetry(req, conn)

      assert %Req.Request{} = result
      assert result != req, "Request should be modified when telemetry is attached"

      bypass = Bypass.open()
      Bypass.expect(bypass, "GET", "/", fn conn ->
        Plug.Conn.send_resp(conn, 200, "OK")
      end)

      Req.get(result, url: "http://localhost:#{bypass.port}")

      assert_receive {[:req, :request, :pipeline, :start], ^ref, _measurements, _metadata}
      assert_receive {[:req, :request, :pipeline, :stop], ^ref, _measurements, _metadata}

      :telemetry.detach(ref)
    end
  end
end
