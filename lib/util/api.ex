defmodule ExOanda.API do
  @moduledoc false

  alias ExOanda.Connection, as: Conn
  alias ExOanda.Transform, as: TF
  alias ExOanda.TransportError

  # Requests ###################################################################

  @base_headers [
    accept: "application/json",
    "user-agent": "ExOanda/" <> Mix.Project.config()[:version]
  ]

  @success_codes Enum.to_list(200..299)

  @spec auth_bearer(Conn.t()) :: {:bearer, String.t()}
  def auth_bearer(%Conn{token: token}) do
    {:bearer, token}
  end

  @spec base_headers([{atom(), String.t()}]) :: Keyword.t()
  def base_headers(opts \\ []), do: Keyword.merge(@base_headers, opts)

  # Responses ####################################################################

  @spec handle_response({atom(), Req.Response.t() | map()}, atom() | nil) :: {:ok, any()} | {:error, any()}
  def handle_response(res, transform_to \\ nil) do
    case format_response(res) do
      # 2xx status codes
      {:ok, fr} -> {:ok, TF.transform(fr, transform_to)}

      # Req transport errors
      {:error, %Req.TransportError{} = error} -> {:error, TransportError.exception(error)}

      # Req HTTP errors
      {:error, %Req.HTTPError{} = error} -> {:error, TransportError.exception(error)}


      # Req redirect errors
      {:error, %Req.TooManyRedirectsError{} = error} -> {:error, TransportError.exception(error)}

      # Legacy transport error format (for backward compatibility)
      {:error, %{reason: reason}} -> {:error, TransportError.exception(reason)}

      # Non-2xx status codes (Oanda API errors)
      {:error, fr} -> {:error, TF.transform(fr, transform_to)}

      _ -> res
    end
  end

  defp format_response({:ok, %{status: status} = res}) when status in @success_codes, do: {:ok, res}
  defp format_response({:ok, res}), do: {:error, res}
  defp format_response(res), do: res

  # Telemetry ##############################################################
  @spec maybe_attach_telemetry(Req.Request.t(), Conn.t()) :: Req.Request.t()
  def maybe_attach_telemetry(req, %{telemetry: true} = _conn) do
    ReqTelemetry.attach_default_logger()
    ReqTelemetry.attach(req)
  end
  def maybe_attach_telemetry(req, %{telemetry: false} = _conn), do: req
  def maybe_attach_telemetry(req, _), do: req
end
