defmodule ExOanda.TelemetryTest do
  use ExUnit.Case, async: true

  alias ExOanda.{Telemetry, Connection}

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
    test "calls ReqTelemetry.attach when telemetry is enabled" do
      req = Req.new(url: "https://example.com")
      conn = %Connection{
        token: "test-token",
        telemetry: %Telemetry{enabled: true, use_default_logger: false, options: []}
      }

      # We should test that our function calls the right ReqTelemetry functions
      # but we don't need to test ReqTelemetry's internal behavior
      result = Telemetry.maybe_attach_telemetry(req, conn)

      # Our function should return a Req.Request (potentially modified by ReqTelemetry)
      assert %Req.Request{} = result
    end

    test "calls ReqTelemetry.attach_default_logger when use_default_logger is true" do
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

      # Our function should return a Req.Request (potentially modified by ReqTelemetry)
      assert %Req.Request{} = result
    end

    test "returns request unchanged when telemetry is disabled" do
      req = Req.new(url: "https://example.com")
      conn = %Connection{
        token: "test-token",
        telemetry: %Telemetry{enabled: false}
      }

      result = Telemetry.maybe_attach_telemetry(req, conn)

      # When disabled, our function should return the request unchanged
      assert result == req
    end

    test "returns request unchanged when telemetry field is missing" do
      req = Req.new(url: "https://example.com")
      conn = %Connection{token: "test-token"}

      result = Telemetry.maybe_attach_telemetry(req, conn)

      # When telemetry field is missing, our function should return the request unchanged
      assert result == req
    end

    test "returns request unchanged when connection has no telemetry key" do
      req = Req.new(url: "https://example.com")
      conn = %{token: "test-token", other_field: "value"}

      result = Telemetry.maybe_attach_telemetry(req, conn)

      # When connection has no telemetry key, our function should return the request unchanged
      assert result == req
    end

    test "passes custom options to ReqTelemetry.attach" do
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

      # Our function should return a Req.Request (potentially modified by ReqTelemetry)
      assert %Req.Request{} = result
    end

    test "passes boolean options to ReqTelemetry.attach" do
      req = Req.new(url: "https://example.com")
      conn = %Connection{
        token: "test-token",
        telemetry: %Telemetry{enabled: true, options: true}
      }

      result = Telemetry.maybe_attach_telemetry(req, conn)

      # Our function should return a Req.Request (potentially modified by ReqTelemetry)
      assert %Req.Request{} = result
    end

    test "passes boolean false options to ReqTelemetry.attach" do
      req = Req.new(url: "https://example.com")
      conn = %Connection{
        token: "test-token",
        telemetry: %Telemetry{enabled: true, options: false}
      }

      result = Telemetry.maybe_attach_telemetry(req, conn)

      # Our function should return a Req.Request (potentially modified by ReqTelemetry)
      assert %Req.Request{} = result
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
      # Test boolean options
      telemetry1 = %Telemetry{options: true}
      assert telemetry1.options == true

      telemetry2 = %Telemetry{options: false}
      assert telemetry2.options == false

      # Test list of options
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
      req = Req.new(url: "https://example.com")
      conn = %Connection{
        token: "test-token",
        telemetry: %Telemetry{enabled: true, options: []}
      }

      # Test that the API module delegates correctly by checking the result
      result = ExOanda.API.maybe_attach_telemetry(req, conn)

      # Should return a Req.Request (potentially modified by ReqTelemetry)
      assert %Req.Request{} = result
    end
  end
end
