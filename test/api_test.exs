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
    test "returns the response as is" do
      response = {:ok, %{"data" => "sample_data"}}
      assert API.handle_response(response) == response
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
      conn = %Conn{token: "abc",}
      assert API.maybe_attach_telemetry(req, conn) == req
    end
  end
end
