defmodule ExOanda.Response do
  @moduledoc """
  Common response schema for Oanda API.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias ExOanda.Type.Atom

  @typedoc """
  Common response schema for ExOanda.

  The type of the `data` field is determined by the Oanda endpoint being called, however, the type of the nested schema is passed as a generic type parameter.
  For example, the response schema for `ExOanda.Accounts.list` is `ExOanda.Response.t(ExOanda.Response.ListAccounts.t())`.
  """

  @type t(data) :: %__MODULE__{
          data: data,
          request_id: String.t(),
          status: atom(),
          error_code: String.t() | nil,
          error_message: String.t() | nil
        }

  @type t() :: %__MODULE__{
          data: nil,
          request_id: String.t(),
          status: atom(),
          error_code: String.t() | nil,
          error_message: String.t() | nil
        }

  embedded_schema do
    field(:data, :map)
    field(:request_id, :string)
    field(:status, Atom)
    field(:error_code, :string)
    field(:error_message, :string)
  end

  @doc false
  def changeset(struct, params) do
    struct
    |> cast(params, [:data, :request_id, :status, :error_code, :error_message])
    |> validate_required([:request_id, :status])
  end
end
