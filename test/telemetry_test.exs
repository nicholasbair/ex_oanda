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
    test "returns request with telemetry attached when enabled is true" do
      req = Req.new(url: "https://example.com")
      conn = %Connection{
        token: "test-token",
        telemetry: %Telemetry{enabled: true, use_default_logger: false, options: []}
      }

      result = Telemetry.maybe_attach_telemetry(req, conn)

      # The function should return a Req.Request struct
      assert %Req.Request{} = result
      # The request should have telemetry attached (ReqTelemetry adds private fields)
      assert Map.has_key?(result.private, :telemetry)
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
      assert Map.has_key?(result.private, :telemetry)
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

      # Should return a Req.Request with telemetry attached
      assert %Req.Request{} = result
      assert Map.has_key?(result.private, :telemetry)
    end
  end
end
