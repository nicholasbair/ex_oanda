defmodule ExOanda.Streaming do
  @moduledoc """
  Interface for Oanda streaming endpoints.
  """

  alias ExOanda.API
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
    stream(conn, account_id, :transactions, stream_to, params)
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
        stream(conn, account_id, :pricing, stream_to, format_instruments(params))
      {:error, errors} ->
        {:error, errors}
    end
  end

  defp stream(%Conn{} = conn, account_id, stream_type, stream_to, params) do
    Req.new(
      auth: API.auth_bearer(conn),
      url: "#{conn.stream_server}/accounts/#{account_id}/#{stream_type}/stream",
      method: :get,
      headers: API.base_headers(),
      params: params,
      into: fn {:data, data}, {req, resp} ->
        data
        |> String.split("\n", trim: true)
        |> Enum.each(fn line ->
          line
          |> TF.transform_stream(stream_type)
          |> stream_to.()
        end)

        {:cont, {req, resp}}
      end
    )
    |> Req.request(conn.options)
  end

  defp format_instruments(params) do
    instruments =
      params
      |> Keyword.fetch!(:instruments)
      |> Enum.join(",")

    %{instruments: instruments}
  end
end
