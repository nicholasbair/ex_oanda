defmodule ExOanda.HttpStatus do
  @moduledoc false

  @status_codes %{
    200 => :ok,
    201 => :created,
    202 => :accepted,
    204 => :no_content,
    400 => :bad_request,
    401 => :unauthorized,
    403 => :forbidden,
    404 => :not_found,
    405 => :method_not_allowed,
    406 => :not_acceptable,
    409 => :conflict,
    410 => :gone,
    411 => :length_required,
    412 => :precondition_failed,
    413 => :payload_too_large,
    414 => :uri_too_long,
    415 => :unsupported_media_type,
    418 => :im_a_teapot,
    429 => :too_many_requests,
    500 => :internal_server_error,
    501 => :not_implemented,
    502 => :bad_gateway,
    503 => :service_unavailable,
    504 => :gateway_timeout
  }

  @doc false
  @spec status_to_atom(integer) :: atom()
  def status_to_atom(status), do: Map.get(@status_codes, status, :unknown)
end
