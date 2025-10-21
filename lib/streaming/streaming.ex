defmodule ExOanda.Streaming do
  @moduledoc """
  Interface for Oanda streaming endpoints.

  ## Oanda Docs
  - [Price Streaming](https://developer.oanda.com/rest-live-v20/pricing-ep/)
  - [Transaction Streaming](https://developer.oanda.com/rest-live-v20/transaction-ep/)
  """

  alias ExOanda.{
    API,
    APIError,
    DecodeError,
    TransportError,
    ValidationError
  }
  alias ExOanda.Connection, as: Conn
  alias ExOanda.Transform, as: TF

  @price_stream_params NimbleOptions.new!(
    instruments: [
      type: {:list, :string},
      required: true
    ]
  )

  @doc """
  Stream transactions for an account.

  ## Examples

      iex> ExOanda.Streaming.transaction_stream(conn, "101-004-22222222-001", &IO.inspect/1)
      :ok
  """
  def transaction_stream(%Conn{} = conn, account_id, stream_to, params \\ []) do
    stream(conn, account_id, :transactions, stream_to, params, false)
  end

  @doc """
  Stream transactions for an account, raising an exception on error.

  ## Examples

      iex> ExOanda.Streaming.transaction_stream!(conn, "101-004-22222222-001", &IO.inspect/1)
      :ok
  """
  def transaction_stream!(%Conn{} = conn, account_id, stream_to, params \\ []) do
    case stream(conn, account_id, :transactions, stream_to, params, true) do
      {:ok, result} -> result
      {:error, %TransportError{} = transport_error} -> raise transport_error
      {:error, %DecodeError{} = decode_error} -> raise decode_error
      {:error, %APIError{} = api_error} -> raise api_error
    end
  end

  @doc """
  Stream prices for an instrument(s).

  ## Examples

      iex> ExOanda.Streaming.price_stream(conn, "101-004-22222222-001", &IO.inspect/1, instruments: ["EUR_USD"])
      :ok

  ## Supported parameters
  #{NimbleOptions.docs(@price_stream_params)}
  """
  def price_stream(%Conn{} = conn, account_id, stream_to, params \\ []) do
    case NimbleOptions.validate(params, @price_stream_params) do
      {:ok, params} ->
        stream(conn, account_id, :pricing, stream_to, format_instruments(params), false)
      {:error, %NimbleOptions.ValidationError{} = validation_error} ->
        {:error, ValidationError.exception(validation_error)}
    end
  end

  @doc """
  Stream prices for an instrument(s), raising an exception on error.

  ## Examples

      iex> ExOanda.Streaming.price_stream!(conn, "101-004-22222222-001", &IO.inspect/1, instruments: ["EUR_USD"])
      :ok

  ## Supported parameters
  #{NimbleOptions.docs(@price_stream_params)}
  """
  def price_stream!(%Conn{} = conn, account_id, stream_to, params \\ []) do
    case NimbleOptions.validate(params, @price_stream_params) do
      {:ok, validated_params} ->
        case stream(conn, account_id, :pricing, stream_to, format_instruments(validated_params), true) do
          {:ok, result} -> result
          {:error, %TransportError{} = transport_error} -> raise transport_error
          {:error, %DecodeError{} = decode_error} -> raise decode_error
          {:error, %APIError{} = api_error} -> raise api_error
        end
      {:error, %NimbleOptions.ValidationError{} = validation_error} ->
        raise ValidationError.exception(validation_error)
    end
  end

  defp stream(%Conn{} = conn, account_id, stream_type, stream_to, params, raise?) do
    transformer = create_transform_fn(stream_type, raise?)

    Req.new(
      auth: API.auth_bearer(conn),
      url: "#{conn.stream_server}/accounts/#{account_id}/#{stream_type}/stream",
      method: :get,
      headers: API.base_headers(),
      params: params,
      into: into(stream_to, transformer)
    )
    |> Req.request(conn.options)
    |> handle_streaming_response()
  end

  defp into(stream_to, transformer) do
    fn {:data, data}, {req, resp} ->
      {processed_buffer, updated_req} =
        req.private
        |> Map.get(:streaming_buffer, "")
        |> Kernel.<>(data)
        |> process_complete_lines(req, transformer, stream_to, resp)

      final_req = put_in(updated_req.private[:streaming_buffer], processed_buffer)
      {:cont, {final_req, resp}}
    end
  end

  defp process_complete_lines(buffer, req, transformer, stream_to, resp) do
    case String.split(buffer, "\n", parts: 2) do
      [complete_line, remaining] ->
        if String.trim(complete_line) == "" do
          process_complete_lines(remaining, req, transformer, stream_to, resp)
        else
          maybe_transform_and_stream(complete_line, transformer, stream_to, resp)
          process_complete_lines(remaining, req, transformer, stream_to, resp)
        end

      [incomplete_line] ->
        {incomplete_line, req}
    end
  end

  defp maybe_transform_and_stream(line, transformer, stream_to, resp) do
    case resp do
      %Req.Response{status: status} when status in 200..299 ->
        line
        |> transformer.()
        |> stream_to.()
      _ ->
        # This is an error response or other non-success status
        # Don't process it - let handle_streaming_response handle it
        :ok
    end
  end

  defp create_transform_fn(stream_type, true = _raise?) do
    fn line ->
      case TF.transform_stream(line, stream_type) do
        {:ok, result} -> result
        {:error, error} -> raise error
      end
    end
  end

  defp create_transform_fn(stream_type, false = _raise?) do
    fn line ->
      case TF.transform_stream(line, stream_type) do
        {:ok, result} -> {:ok, result}
        {:error, error} -> {:error, error}
      end
    end
  end

  defp format_instruments(params) do
    instruments =
      params
      |> Keyword.get(:instruments, [])
      |> Enum.join(",")

    %{instruments: instruments}
  end

  defp handle_streaming_response({:ok, %Req.Response{status: status} = response}) when status in 200..299 do
    {:ok, response}
  end

  defp handle_streaming_response({:ok, %Req.Response{status: status, body: ""}}) do
    {:error, APIError.exception("HTTP #{status} error")}
  end

  # In practice, Oanda's streaming API seems to omit the body on non-2xx responses
  # Including this error handling in case that's not always the case
  defp handle_streaming_response({:ok, %Req.Response{body: body}}) do
    case Jason.decode(body) do
      {:ok, %{"errorMessage" => error_message}} ->
        {:error, APIError.exception(error_message)}

      {:ok, res} ->
        {:error, APIError.exception(res)}

      {:error, error} ->
        {:error, DecodeError.exception(error)}
    end
  end

  defp handle_streaming_response({:error, %Req.TransportError{} = error}) do
    {:error, TransportError.exception(error)}
  end

  defp handle_streaming_response({:error, %Req.HTTPError{} = error}) do
    {:error, TransportError.exception(error)}
  end

  defp handle_streaming_response({:error, %Req.TooManyRedirectsError{} = error}) do
    {:error, TransportError.exception(error)}
  end

  defp handle_streaming_response({:error, reason}) do
    {:error, TransportError.exception(reason)}
  end
end
