defmodule ExOanda.TransportErrorTest do
  use ExUnit.Case, async: true

  alias ExOanda.TransportError

  describe "exception/1" do
    test "creates exception from Req.TransportError" do
      transport_error = %Req.TransportError{reason: :nxdomain}
      exception = TransportError.exception(transport_error)

      assert %TransportError{} = exception
      assert exception.message == "HTTP transport error: nxdomain"
      assert exception.reason == :nxdomain
      assert exception.error_type == :transport
    end

    test "creates exception from Req.TransportError with binary reason" do
      transport_error = %Req.TransportError{reason: "Connection refused"}
      exception = TransportError.exception(transport_error)

      assert %TransportError{} = exception
      assert exception.message == "HTTP transport error: Connection refused"
      assert exception.reason == "Connection refused"
      assert exception.error_type == :transport
    end

    test "creates exception from Req.HTTPError" do
      http_error = %Req.HTTPError{protocol: :http1, reason: :invalid_request}
      exception = TransportError.exception(http_error)

      assert %TransportError{} = exception
      assert exception.message == "HTTP http1 error: invalid_request"
      assert exception.reason == :invalid_request
      assert exception.error_type == :http
    end

    test "creates exception from Req.HTTPError with binary reason" do
      http_error = %Req.HTTPError{protocol: :http2, reason: "Invalid response"}
      exception = TransportError.exception(http_error)

      assert %TransportError{} = exception
      assert exception.message == "HTTP http2 error: Invalid response"
      assert exception.reason == "Invalid response"
      assert exception.error_type == :http
    end

    test "creates exception from Req.TransportError with complex reason" do
      transport_error = %Req.TransportError{reason: [1, 2, 3]}
      exception = TransportError.exception(transport_error)

      assert %TransportError{} = exception
      assert exception.message == "HTTP transport error: [1, 2, 3]"
      assert exception.reason == [1, 2, 3]
      assert exception.error_type == :transport
    end

    test "creates exception from Req.HTTPError with complex reason" do
      http_error = %Req.HTTPError{protocol: :http1, reason: %{error: "test"}}
      exception = TransportError.exception(http_error)

      assert %TransportError{} = exception
      assert exception.message == "HTTP http1 error: %{error: \"test\"}"
      assert exception.reason == %{error: "test"}
      assert exception.error_type == :http
    end

    test "creates exception from Req.TransportError with timeout reason" do
      timeout_error = %Req.TransportError{reason: :timeout}
      exception = TransportError.exception(timeout_error)

      assert %TransportError{} = exception
      assert exception.message == "HTTP timeout: timeout"
      assert exception.reason == :timeout
      assert exception.error_type == :timeout
    end

    test "creates exception from Req.TooManyRedirectsError" do
      redirect_error = %Req.TooManyRedirectsError{}
      exception = TransportError.exception(redirect_error)

      assert %TransportError{} = exception
      assert exception.message == "Too many redirects"
      assert exception.reason == :too_many_redirects
      assert exception.error_type == :http
    end

    test "creates exception from atom reason" do
      exception = TransportError.exception(:connection_refused)

      assert %TransportError{} = exception
      assert exception.message == "HTTP error: connection_refused"
      assert exception.reason == :connection_refused
      assert exception.error_type == :other
    end

    test "creates exception from string reason" do
      exception = TransportError.exception("Connection failed")

      assert %TransportError{} = exception
      assert exception.message == "HTTP error: Connection failed"
      assert exception.reason == "Connection failed"
      assert exception.error_type == :other
    end

    test "creates exception from other values" do
      exception = TransportError.exception(%{some: "complex", data: 123})

      assert %TransportError{} = exception
      assert exception.message == "HTTP error: %{data: 123, some: \"complex\"}"
      assert exception.reason == %{some: "complex", data: 123}
      assert exception.error_type == :other
    end
  end

  describe "format_reason/1" do
    test "formats atom reasons" do
      assert TransportError.exception(:timeout).message == "HTTP error: timeout"
    end

    test "formats string reasons" do
      assert TransportError.exception("Connection failed").message == "HTTP error: Connection failed"
    end

    test "formats complex reasons" do
      complex_reason = %{error: "test", code: 123}
      exception = TransportError.exception(complex_reason)
      assert exception.message =~ "HTTP error: %{"
      assert exception.message =~ "code: 123"
      assert exception.message =~ "error: \"test\""
    end

    test "formats numeric reasons" do
      exception = TransportError.exception(404)
      assert exception.message == "HTTP error: 404"
      assert exception.reason == 404
      assert exception.error_type == :other
    end

    test "formats list reasons" do
      list_reason = [1, 2, 3]
      exception = TransportError.exception(list_reason)
      assert exception.message == "HTTP error: [1, 2, 3]"
      assert exception.reason == [1, 2, 3]
      assert exception.error_type == :other
    end

    test "formats float reasons" do
      exception = TransportError.exception(3.14)
      assert exception.message == "HTTP error: 3.14"
      assert exception.reason == 3.14
      assert exception.error_type == :other
    end

    test "formats tuple reasons" do
      tuple_reason = {:error, "test"}
      exception = TransportError.exception(tuple_reason)
      assert exception.message == "HTTP error: {:error, \"test\"}"
      assert exception.reason == {:error, "test"}
      assert exception.error_type == :other
    end
  end

  describe "exception behavior" do
    test "TransportError can be raised and caught" do
      error = %TransportError{message: "test error", reason: :test, error_type: :other}

      assert_raise TransportError, "test error", fn ->
        raise error
      end
    end
  end
end
