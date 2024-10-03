defmodule ExOanda.ListAccounts do
  @moduledoc """
  Schema for Oanda list accounts response.
  """

  use TypedEctoSchema
  import Ecto.Changeset

  @primary_key false

  typed_embedded_schema do
    embeds_many :accounts, AccountProperties, primary_key: false do
      field(:id, :string)
      field(:mt4_account_id, :integer)
      field(:tags, {:array, :string}, default: [])
    end
  end

  @doc false
  def changeset(struct, params) do
    struct
    |> cast(params, [])
    |> cast_embed(:accounts, with: &account_properties_changeset/2)
  end

  defp account_properties_changeset(struct, params) do
    struct
    |> cast(params, [:id, :mt4_account_id, :tags])
    |> validate_required([:id])
  end
end
