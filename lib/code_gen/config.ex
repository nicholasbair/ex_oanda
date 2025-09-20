defmodule ExOanda.Config do
  @moduledoc false

  use TypedEctoSchema
  import Ecto.Changeset

  @config_file "./config.yml"

  @primary_key false

  typed_embedded_schema do
    field(:module_name, :string)
    field(:description, :string)
    field(:docs_link, :string)

    embeds_many :functions, Functions, primary_key: false do
      field(:function_name, :string)
      field(:description, :string)
      field(:http_method, :string)
      field(:path, :string)
      field(:arguments, {:array, :string}, default: [])
      field(:response_schema, :string)
      field(:request_schema, :string)

      embeds_many :parameters, Parameters, primary_key: false do
        field(:name, :string)
        field(:type, :string)
        field(:required, :boolean, default: false)
        field(:default, :string)
        field(:doc, :string)
      end
    end
  end

  @doc false
  def changeset(config, params \\ %{}) do
    config
    |> cast(params, [:module_name, :description, :docs_link])
    |> validate_required([:module_name, :description])
    |> cast_embed(:functions, with: &functions_changeset/2)
  end

  @doc false
  def load_config do
    @config_file
    |> YamlElixir.read_all_from_file!()
    |> List.first()
    |> Map.fetch!("interfaces")
    |> Enum.map(&cast_to_config/1)
  end

  defp cast_to_config(input) do
    %__MODULE__{}
    |> changeset(input)
    |> apply_changes()
  end

  defp functions_changeset(struct, params) do
    struct
    |> cast(params, [
      :function_name,
      :description,
      :http_method,
      :path,
      :arguments,
      :request_schema,
      :response_schema
    ])
    |> validate_required([:function_name, :description, :http_method, :path])
    |> cast_embed(:parameters, with: &embedded_changeset/2)
  end

  defp embedded_changeset(struct, params) do
    keys =
      struct
      |> Map.keys()
      |> Enum.reject(&(&1 in [:__meta__, :__struct__]))

    struct
    |> cast(params, keys)
  end
end
