defmodule ExOandaTest.API do
  use ExUnit.Case, async: true
  alias ExOanda.API
  alias ExOanda.Connection, as: Conn

  describe "auth_bearer/1" do
    test "returns the bearer token tuple" do
      conn = %Conn{token: "sample_token"}
      assert API.auth_bearer(conn) == {:bearer, "sample_token"}
    end
  end

  describe "base_headers/1" do
    test "returns the base headers without any additional options" do
      expected_headers = [
        accept: "application/json",
        "user-agent": "ExOanda/" <> Mix.Project.config()[:version]
      ]

      assert API.base_headers() == expected_headers
    end

    test "merges additional headers with the base headers" do
      additional_headers = [authorization: "Bearer token"]
      expected_headers = [
        accept: "application/json",
        "user-agent": "ExOanda/" <> Mix.Project.config()[:version],
        authorization: "Bearer token"
      ]

      assert API.base_headers(additional_headers) == expected_headers
    end
  end

  describe "handle_response/1" do
    test "returns {:ok, _} for 2xx responses" do
      res = API.handle_response({:ok, %{status: 200}})
      assert match?({:ok, _}, res)
    end

    test "returns {:error, _} for non-2xx responses" do
      res = API.handle_response({:error, %{status: 400}})
      assert match?({:error, _}, res)
    end

    test "returns {:error, _} for {:ok, non-2xx} responses" do
      res = API.handle_response({:ok, %{status: 400}})
      assert match?({:error, _}, res)
    end

    test "returns {:error, reason} for HTTP issues, e.g. timeout" do
      assert API.handle_response({:error, %Req.TransportError{reason: :nxdomain}}) == {:error, :nxdomain}
    end

    test "returns the response unchanged for unexpected format" do
      unexpected_response = {:unexpected, "data"}
      assert API.handle_response(unexpected_response) == unexpected_response
    end

    test "returns the response unchanged for non-tuple responses" do
      unexpected_response = "just a string"
      assert API.handle_response(unexpected_response) == unexpected_response
    end
  end

  describe "handle_response/2" do
    test "returns {:ok, _} for 2xx responses with transform" do
      response = {:ok, %{status: 200, body: %{"data" => "test"}}}
      res = API.handle_response(response, nil)
      assert match?({:ok, _}, res)
    end

    test "returns {:error, _} for non-2xx responses with transform" do
      response = {:error, %{status: 400, body: %{"error" => "bad request"}}}
      res = API.handle_response(response, nil)
      assert match?({:error, _}, res)
    end

    test "returns {:error, reason} for HTTP issues with transform" do
      response = {:error, %Req.TransportError{reason: :timeout}}
      res = API.handle_response(response, nil)
      assert res == {:error, :timeout}
    end

    test "returns the response unchanged for unexpected format with transform" do
      unexpected_response = {:unexpected, "data"}
      assert API.handle_response(unexpected_response, nil) == unexpected_response
    end
  end

  describe "maybe_attach_telemetry/2" do
    setup do
      req = %Req.Request{}
      {:ok, req: req}
    end

    test "attaches telemetry when telemetry is enabled in the connection", %{req: req} do
      conn = %Conn{token: "abc", telemetry: true}
      res = API.maybe_attach_telemetry(req, conn)

      assert res.private.telemetry != nil
    end

    test "returns the request unchanged when telemetry is disabled", %{req: req} do
      conn = %Conn{token: "abc", telemetry: false}
      assert API.maybe_attach_telemetry(req, conn) == req
    end

    test "returns the request unchanged when telemetry key is missing", %{req: req} do
      conn = %Conn{token: "abc"}
      assert API.maybe_attach_telemetry(req, conn) == req
    end

    test "returns the request unchanged when connection has no telemetry key", %{req: req} do
      conn = %{token: "abc", other_field: "value"}
      assert API.maybe_attach_telemetry(req, conn) == req
    end
  end
end
