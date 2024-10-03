defmodule ExOanda.Order do
  @moduledoc """
  Schema for Oanda order.
  """

  use TypedEctoSchema
  import Ecto.Changeset

  @primary_key false

  typed_embedded_schema do
    field(:id, :string)
    field(:creat_time, :utc_datetime_usec)
    field(:state, :string)

    embeds_many :client_extensions, ClientExtensions, primary_key: false do
      field(:id, :string)
      field(:tag, :string)
      field(:comment, :string)
    end
  end

  @doc false
  def changeset(struct, params) do
    struct
    |> cast(params, [:id, :creat_time, :state])
    |> cast_embed(:client_extensions, with: &client_extensions_changeset/2)
    |> validate_required([:id, :creat_time, :state])
  end

  defp client_extensions_changeset(struct, params) do
    struct
    |> cast(params, [:id, :tag, :comment])
    |> validate_required([:id])
  end
end
