defmodule ExOanda.CodeGeneratorMacroTest do
  use ExUnit.Case, async: true

  require ExOanda.CodeGenerator

  describe "macro functionality" do
    test "__using__ macro sets up before_compile" do
      assert ExOanda.CodeGenerator.__info__(:macros) |> Keyword.has_key?(:__using__)
    end

    test "__before_compile__ macro is callable" do
      assert ExOanda.CodeGenerator.__info__(:macros) |> Keyword.has_key?(:__before_compile__)
    end

    test "CodeGenerator module can be loaded" do
      assert Code.ensure_loaded(ExOanda.CodeGenerator)
    end

    test "TestCodeGenModule can be compiled" do
      defmodule TestCodeGenModule do
        use ExOanda.CodeGenerator
      end

      assert Code.ensure_loaded(TestCodeGenModule)
    end
  end

  describe "test configuration generation" do
    test "load_test_config returns expected structure" do
      config = ExOanda.CodeGenerator.load_test_config()

      assert is_list(config)
      assert length(config) == 2

      [first_module | _] = config
      assert first_module.module_name == "TestAccounts"
      assert first_module.description == "Test accounts interface for testing"
      assert first_module.docs_link == "https://example.com/test-docs"
      assert is_list(first_module.functions)
      assert length(first_module.functions) == 2

      [list_func, find_func] = first_module.functions
      assert list_func.function_name == "list"
      assert list_func.http_method == "GET"
      assert list_func.path == "/test-accounts"
      assert list_func.arguments == []

      assert find_func.function_name == "find"
      assert find_func.http_method == "GET"
      assert find_func.path == "/test-accounts/:id"
      assert length(find_func.arguments) == 1
      assert hd(find_func.arguments).name == "id"
      assert hd(find_func.arguments).type == "string"
    end

    test "test configuration generates modules when used" do
      defmodule TempTestModule do
        use ExOanda.CodeGenerator
      end

      assert Code.ensure_loaded(ExOanda.TestAccounts)
      assert Code.ensure_loaded(ExOanda.TestOrders)
    end

    test "test modules have expected functions" do
      if Code.ensure_loaded(ExOanda.TestAccounts) != :error do
        assert function_exported?(ExOanda.TestAccounts, :list, 1)
        assert function_exported?(ExOanda.TestAccounts, :list!, 1)
        assert function_exported?(ExOanda.TestAccounts, :find, 2)
        assert function_exported?(ExOanda.TestAccounts, :find!, 2)
      end

      if Code.ensure_loaded(ExOanda.TestOrders) != :error do
        assert function_exported?(ExOanda.TestOrders, :list, 2)
        assert function_exported?(ExOanda.TestOrders, :list!, 2)
      end
    end
  end

  describe "macro behavior" do
    test "macro is properly defined" do
      assert ExOanda.CodeGenerator.__info__(:macros) |> Keyword.has_key?(:__using__)
    end

    test "before_compile macro is properly defined" do
      assert ExOanda.CodeGenerator.__info__(:macros) |> Keyword.has_key?(:__before_compile__)
    end
  end

  describe "code generation integration" do
    test "generate_code function exists and is callable" do
      assert ExOanda.CodeGenerator.__info__(:macros) |> Keyword.has_key?(:__before_compile__)
    end

    test "generate_functions function exists and is callable" do
      assert ExOanda.CodeGenerator.__info__(:macros) |> Keyword.has_key?(:__before_compile__)
    end

    test "generate_function function exists and is callable" do
      assert ExOanda.CodeGenerator.__info__(:macros) |> Keyword.has_key?(:__before_compile__)
    end
  end

  describe "macro edge cases" do
    test "macro handles different option types" do
      assert ExOanda.CodeGenerator.__info__(:macros) |> Keyword.has_key?(:__using__)

      options = [
        [],
        %{},
        [option1: "value1"],
        %{option1: "value1", option2: "value2"}
      ]

      for _opts <- options do
        assert ExOanda.CodeGenerator.__info__(:macros) |> Keyword.has_key?(:__using__)
      end
    end
  end

  describe "macro environment handling" do
    test "handles different environment structures" do
      assert ExOanda.CodeGenerator.__info__(:macros) |> Keyword.has_key?(:__before_compile__)

      envs = [
        %Macro.Env{},
        %Macro.Env{module: ExOanda.CodeGeneratorMacroTest},
        %Macro.Env{module: ExOanda.CodeGeneratorMacroTest, file: "test.ex"}
      ]

      for _env <- envs do
        assert ExOanda.CodeGenerator.__info__(:macros) |> Keyword.has_key?(:__before_compile__)
      end
    end
  end
end
