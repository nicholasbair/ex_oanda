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

    test "returns {:error, TransportError} for HTTP issues, e.g. timeout" do
      result = API.handle_response({:error, %Req.TransportError{reason: :nxdomain}})
      assert {:error, %ExOanda.TransportError{}} = result
      assert elem(result, 1).reason == :nxdomain
      assert elem(result, 1).error_type == :transport
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

    test "returns {:error, TransportError} for HTTP issues with transform" do
      response = {:error, %Req.TransportError{reason: :timeout}}
      res = API.handle_response(response, nil)
      assert {:error, %ExOanda.TransportError{}} = res
      assert elem(res, 1).reason == :timeout
      assert elem(res, 1).error_type == :timeout
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

    test "delegates to Telemetry.maybe_attach_telemetry/2", %{req: req} do
      conn = %Conn{token: "abc", telemetry: %ExOanda.Telemetry{enabled: true}}

      result = API.maybe_attach_telemetry(req, conn)

      assert %Req.Request{} = result
    end
  end
end
