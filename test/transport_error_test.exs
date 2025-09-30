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

    test "creates exception from Req.HTTPError" do
      http_error = %Req.HTTPError{protocol: :http1, reason: :invalid_request}
      exception = TransportError.exception(http_error)

      assert %TransportError{} = exception
      assert exception.message == "HTTP http1 error: invalid_request"
      assert exception.reason == :invalid_request
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
  end

  describe "exception behavior" do
    test "TransportError can be raised and caught" do
      error = %TransportError{message: "test error", reason: :test, error_type: :other}

      assert_raise TransportError, "test error", fn ->
        raise error
      end
    end
  end

  describe "format_reason edge cases" do
    test "handles nil reason" do
      exception = TransportError.exception(nil)

      assert %TransportError{} = exception
      assert exception.message == "HTTP error: "
      assert exception.reason == nil
      assert exception.error_type == :other
    end

    test "handles boolean reason" do
      exception = TransportError.exception(true)

      assert %TransportError{} = exception
      assert exception.message == "HTTP error: true"
      assert exception.reason == true
      assert exception.error_type == :other
    end

    test "handles numeric reason" do
      exception = TransportError.exception(42)

      assert %TransportError{} = exception
      assert exception.message == "HTTP error: 42"
      assert exception.reason == 42
      assert exception.error_type == :other
    end

    test "handles list reason" do
      exception = TransportError.exception([1, 2, 3])

      assert %TransportError{} = exception
      assert exception.message == "HTTP error: [1, 2, 3]"
      assert exception.reason == [1, 2, 3]
      assert exception.error_type == :other
    end
  end
end
