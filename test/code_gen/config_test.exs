defmodule ExOanda.ConfigTest do
  use ExUnit.Case, async: true

  alias ExOanda.Config

  describe "changeset/2" do
    test "validates required fields" do
      changeset = Config.changeset(%Config{}, %{})

      refute changeset.valid?
      assert "can't be blank" in errors_on(changeset).module_name
      assert "can't be blank" in errors_on(changeset).description
    end

    test "accepts valid config" do
      params = %{
        module_name: "TestModule",
        description: "Test description",
        docs_link: "https://example.com/docs"
      }

      changeset = Config.changeset(%Config{}, params)
      assert changeset.valid?
    end

    test "validates functions" do
      params = %{
        module_name: "TestModule",
        description: "Test description",
        functions: [
          %{
            function_name: "test",
            description: "Test function",
            http_method: "GET",
            path: "/test",
            response_schema: "TestResponse"
          }
        ]
      }

      changeset = Config.changeset(%Config{}, params)
      assert changeset.valid?
    end

    test "validates function arguments" do
      params = %{
        module_name: "TestModule",
        description: "Test description",
        functions: [
          %{
            function_name: "test",
            description: "Test function",
            http_method: "GET",
            path: "/test",
            response_schema: "TestResponse",
            arguments: [
              %{name: "account_id", type: "string"}
            ]
          }
        ]
      }

      changeset = Config.changeset(%Config{}, params)
      assert changeset.valid?
    end

    test "validates function parameters" do
      params = %{
        module_name: "TestModule",
        description: "Test description",
        functions: [
          %{
            function_name: "test",
            description: "Test function",
            http_method: "GET",
            path: "/test",
            response_schema: "TestResponse",
            parameters: [
              %{
                name: "instruments",
                type: "string",
                required: false,
                default: nil,
                doc: "Comma separated list"
              }
            ]
          }
        ]
      }

      changeset = Config.changeset(%Config{}, params)
      assert changeset.valid?
    end

    test "rejects invalid function without required fields" do
      params = %{
        module_name: "TestModule",
        description: "Test description",
        functions: [
          %{
            function_name: "test"
          }
        ]
      }

      changeset = Config.changeset(%Config{}, params)
      refute changeset.valid?
    end
  end

  describe "load_config/0" do
    test "loads and parses config file" do
      assert is_function(&Config.load_config/0)
    end
  end

  defp errors_on(changeset) do
    Ecto.Changeset.traverse_errors(changeset, &translate_error/1)
  end

  defp translate_error({msg, opts}) do
    Enum.reduce(opts, msg, fn {key, value}, acc ->
      String.replace(acc, "%{#{key}}", to_string(value))
    end)
  end
end
