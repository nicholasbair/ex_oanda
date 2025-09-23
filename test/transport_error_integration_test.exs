defmodule ExOanda.TransportErrorIntegrationTest do
  use ExUnit.Case, async: true

  alias ExOanda.TransportError

  describe "API error handling" do
    test "handle_response returns TransportError for transport errors" do
      transport_error = %Req.TransportError{reason: :nxdomain}
      result = ExOanda.API.handle_response({:error, transport_error})

      assert {:error, %TransportError{} = error} = result
      assert error.message == "HTTP transport error: nxdomain"
      assert error.reason == :nxdomain
      assert error.error_type == :transport
    end

    test "handle_response returns TransportError for HTTP errors" do
      http_error = %Req.HTTPError{protocol: :http1, reason: :invalid_request}
      result = ExOanda.API.handle_response({:error, http_error})

      assert {:error, %TransportError{} = error} = result
      assert error.message == "HTTP http1 error: invalid_request"
      assert error.reason == :invalid_request
      assert error.error_type == :http
    end

    test "handle_response returns TransportError for timeout errors" do
      timeout_error = %Req.TransportError{reason: :timeout}
      result = ExOanda.API.handle_response({:error, timeout_error})

      assert {:error, %TransportError{} = error} = result
      assert error.message == "HTTP timeout: timeout"
      assert error.reason == :timeout
      assert error.error_type == :timeout
    end

    test "handle_response returns TransportError for redirect errors" do
      redirect_error = %Req.TooManyRedirectsError{}
      result = ExOanda.API.handle_response({:error, redirect_error})

      assert {:error, %TransportError{} = error} = result
      assert error.message == "Too many redirects"
      assert error.reason == :too_many_redirects
      assert error.error_type == :http
    end

    test "handle_response returns TransportError for legacy error format" do
      legacy_error = %{reason: :connection_refused}
      result = ExOanda.API.handle_response({:error, legacy_error})

      assert {:error, %TransportError{} = error} = result
      assert error.message == "HTTP error: connection_refused"
      assert error.reason == :connection_refused
      assert error.error_type == :other
    end
  end

  describe "error type classification" do
    test "transport errors are classified correctly" do
      error = TransportError.exception(%Req.TransportError{reason: :nxdomain})
      assert error.error_type == :transport
    end

    test "http errors are classified correctly" do
      error = TransportError.exception(%Req.HTTPError{protocol: :http1, reason: :invalid_request})
      assert error.error_type == :http
    end

    test "timeout errors are classified correctly" do
      error = TransportError.exception(%Req.TransportError{reason: :timeout})
      assert error.error_type == :timeout
    end


    test "other errors are classified correctly" do
      error = TransportError.exception(:unknown_error)
      assert error.error_type == :other
    end
  end
end
