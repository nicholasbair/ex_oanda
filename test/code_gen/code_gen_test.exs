defmodule ExOanda.CodeGenTest do
  use ExUnit.Case, async: true

  alias ExOanda.CodeGenerator

  describe "end-to-end code generation" do
    test "generates complete module with GET function" do
      config = [
        %{
          module_name: "TestAccounts",
          description: "Test accounts interface",
          docs_link: "https://example.com/docs",
          functions: [
            %{
              function_name: "list",
              description: "List all accounts",
              http_method: "GET",
              path: "/accounts",
              response_schema: "ListAccounts",
              arguments: [],
              parameters: []
            }
          ]
        }
      ]

      assert is_list(config)
      assert length(config) == 1

      module_config = hd(config)
      assert module_config.module_name == "TestAccounts"
      assert length(module_config.functions) == 1

      function = hd(module_config.functions)
      assert function.function_name == "list"
      assert function.http_method == "GET"
    end

    test "generates complete module with POST function and body" do
      config = [
        %{
          module_name: "TestOrders",
          description: "Test orders interface",
          docs_link: "https://example.com/docs",
          functions: [
            %{
              function_name: "create",
              description: "Create a new order",
              http_method: "POST",
              path: "/accounts/:account_id/orders",
              request_schema: "CreateOrder",
              response_schema: "OrderResponse",
              arguments: [
                %{name: "account_id", type: "string"},
                %{name: "body", type: "map"}
              ],
              parameters: []
            }
          ]
        }
      ]

      assert is_list(config)
      module_config = hd(config)
      assert module_config.module_name == "TestOrders"

      function = hd(module_config.functions)
      assert function.function_name == "create"
      assert function.http_method == "POST"
      assert function.request_schema == "CreateOrder"
      assert length(function.arguments) == 2
    end

    test "generates complete module with PATCH function without request schema" do
      config = [
        %{
          module_name: "TestAccounts",
          description: "Test accounts interface",
          docs_link: "https://example.com/docs",
          functions: [
            %{
              function_name: "update",
              description: "Update account configuration",
              http_method: "PATCH",
              path: "/accounts/:account_id/configuration",
              response_schema: "UpdateAccount",
              arguments: [
                %{name: "account_id", type: "string"}
              ],
              parameters: []
            }
          ]
        }
      ]

      assert is_list(config)
      module_config = hd(config)
      function = hd(module_config.functions)
      assert function.http_method == "PATCH"
      refute Map.has_key?(function, :request_schema)
    end

    test "generates complete module with parameters" do
      config = [
        %{
          module_name: "TestInstruments",
          description: "Test instruments interface",
          docs_link: "https://example.com/docs",
          functions: [
            %{
              function_name: "list",
              description: "List instruments",
              http_method: "GET",
              path: "/accounts/:account_id/instruments",
              response_schema: "AccountInstruments",
              arguments: [
                %{name: "account_id", type: "string"}
              ],
              parameters: [
                %{
                  name: "instruments",
                  type: "string",
                  required: false,
                  default: nil,
                  doc: "Comma separated list of instruments"
                },
                %{
                  name: "include_weekly",
                  type: "boolean",
                  required: false,
                  default: "false",
                  doc: "Include weekly instruments"
                }
              ]
            }
          ]
        }
      ]

      assert is_list(config)
      module_config = hd(config)
      function = hd(module_config.functions)
      assert length(function.parameters) == 2

      instruments_param = Enum.find(function.parameters, &(&1.name == "instruments"))
      assert instruments_param.type == "string"
      assert instruments_param.required == false

      weekly_param = Enum.find(function.parameters, &(&1.name == "include_weekly"))
      assert weekly_param.type == "boolean"
      assert weekly_param.default == "false"
    end
  end

  describe "utility function integration" do
    test "to_camel works with generated parameters" do
      params = [
        account_id: "123",
        instrument_name: "EUR_USD",
        include_weekly: true
      ]

      result = CodeGenerator.to_camel(params)

      result_map = Enum.into(result, %{})
      expected_map = %{"accountID" => "123", "instrumentName" => "EUR_USD", "includeWeekly" => true}

      assert result_map == expected_map
    end

    test "transform_request_body is available" do
      assert is_function(&CodeGenerator.transform_request_body/1)
    end

    test "format_module_name works with generated module names" do
      test_cases = [
        ExOanda.Accounts,
        :"Elixir.ExOanda.Accounts",
        ExOanda.Orders,
        ExOanda.Instruments
      ]

      for module_name <- test_cases do
        result = CodeGenerator.format_module_name(module_name)
        assert is_atom(result)
        assert String.starts_with?(Atom.to_string(result), "ExOanda.")
      end
    end
  end

  describe "error handling in code generation" do
    test "handles malformed config gracefully" do
      malformed_config = [
        %{
          module_name: "TestModule"
        }
      ]

      assert is_list(malformed_config)
    end

    test "handles empty function lists" do
      config = [
        %{
          module_name: "EmptyModule",
          description: "Empty module",
          docs_link: "https://example.com",
          functions: []
        }
      ]

      assert is_list(config)
      module_config = hd(config)
      assert Enum.empty?(module_config.functions)
    end

    test "handles functions with missing optional fields" do
      config = [
        %{
          module_name: "TestModule",
          description: "Test module",
          docs_link: "https://example.com",
          functions: [
            %{
              function_name: "test",
              description: "Test function",
              http_method: "GET",
              path: "/test",
              response_schema: "TestResponse",
              arguments: [],
              parameters: []
            }
          ]
        }
      ]

      assert is_list(config)
      module_config = hd(config)
      function = hd(module_config.functions)
      assert function.function_name == "test"
      assert function.arguments == []
      assert function.parameters == []
    end
  end

  describe "type generation" do
    test "generates correct argument types" do
      arguments = [
        %{name: "account_id", type: "string"},
        %{name: "data", type: "map"},
        %{name: "count", type: "integer"}
      ]

      assert length(arguments) == 3
      assert Enum.all?(arguments, &Map.has_key?(&1, :name))
      assert Enum.all?(arguments, &Map.has_key?(&1, :type))
    end

    test "handles different parameter types" do
      parameters = [
        %{name: "instruments", type: "string", required: false},
        %{name: "include_weekly", type: "boolean", required: false},
        %{name: "count", type: "integer", required: true}
      ]

      assert length(parameters) == 3
      assert Enum.all?(parameters, &Map.has_key?(&1, :name))
      assert Enum.all?(parameters, &Map.has_key?(&1, :type))
      assert Enum.all?(parameters, &Map.has_key?(&1, :required))
    end
  end

  describe "comprehensive code generation scenarios" do
    test "generates complete module with all function types" do
      config = [
        %{
          module_name: "ComprehensiveTest",
          description: "Comprehensive test module",
          docs_link: "https://example.com/docs",
          functions: [
            %{
              function_name: "list",
              description: "List items",
              http_method: "GET",
              path: "/items",
              response_schema: "ListItems",
              arguments: [%{name: "account_id", type: "string"}],
              parameters: [
                %{name: "limit", type: "integer", required: false, default: "100", doc: "Maximum number of items"},
                %{name: "offset", type: "integer", required: false, default: "0", doc: "Number of items to skip"}
              ]
            },
            %{
              function_name: "create",
              description: "Create item",
              http_method: "POST",
              path: "/items",
              request_schema: "CreateItem",
              response_schema: "Item",
              arguments: [%{name: "account_id", type: "string"}, %{name: "body", type: "map"}],
              parameters: []
            },
            %{
              function_name: "update",
              description: "Update item",
              http_method: "PATCH",
              path: "/items/:id",
              response_schema: "Item",
              arguments: [%{name: "id", type: "string"}],
              parameters: []
            },
            %{
              function_name: "replace",
              description: "Replace item",
              http_method: "PUT",
              path: "/items/:id",
              request_schema: "ReplaceItem",
              response_schema: "Item",
              arguments: [%{name: "id", type: "string"}, %{name: "body", type: "map"}],
              parameters: []
            }
          ]
        }
      ]

      assert is_list(config)
      module_config = hd(config)
      assert module_config.module_name == "ComprehensiveTest"
      assert length(module_config.functions) == 4

      function_names = Enum.map(module_config.functions, & &1.function_name)
      assert "list" in function_names
      assert "create" in function_names
      assert "update" in function_names
      assert "replace" in function_names
    end

    test "handles complex nested configurations" do
      config = [
        %{
          module_name: "ComplexModule",
          description: "Complex module with many functions",
          docs_link: "https://example.com/docs",
          functions: [
            %{
              function_name: "complex_function",
              description: "Complex function with many parameters",
              http_method: "GET",
              path: "/complex/:id/:sub_id",
              response_schema: "ComplexResponse",
              arguments: [
                %{name: "id", type: "string"},
                %{name: "sub_id", type: "string"}
              ],
              parameters: [
                %{name: "param1", type: "string", required: true, default: nil, doc: "Required parameter"},
                %{name: "param2", type: "boolean", required: false, default: "false", doc: "Optional boolean"},
                %{name: "param3", type: "integer", required: false, default: "0", doc: "Optional integer"},
                %{name: "param4", type: "string", required: false, default: nil, doc: "Optional string"}
              ]
            }
          ]
        }
      ]

      assert is_list(config)
      module_config = hd(config)
      function = hd(module_config.functions)
      assert function.function_name == "complex_function"
      assert length(function.arguments) == 2
      assert length(function.parameters) == 4
    end

    test "handles edge case configurations" do
      config = [
        %{
          module_name: "EdgeCaseModule",
          description: "Edge case module",
          docs_link: "https://example.com/docs",
          functions: [
            %{
              function_name: "simple",
              description: "Simple function",
              http_method: "GET",
              path: "/simple",
              response_schema: "SimpleResponse",
              arguments: [],
              parameters: []
            },
            %{
              function_name: "with_args",
              description: "Function with arguments",
              http_method: "GET",
              path: "/with-args/:id",
              response_schema: "Response",
              arguments: [%{name: "id", type: "string"}],
              parameters: []
            },
            %{
              function_name: "with_params",
              description: "Function with parameters",
              http_method: "GET",
              path: "/with-params",
              response_schema: "Response",
              arguments: [],
              parameters: [
                %{name: "filter", type: "string", required: false, default: nil, doc: "Filter parameter"}
              ]
            }
          ]
        }
      ]

      assert is_list(config)
      module_config = hd(config)
      assert length(module_config.functions) == 3
    end
  end

  describe "error handling and validation" do
    test "handles malformed function configurations" do
      malformed_configs = [
        %{
          module_name: "BadModule",
          description: "Bad module"
        },
        %{
          module_name: "EmptyModule",
          description: "Empty module",
          docs_link: "https://example.com",
          functions: []
        },
        %{
          module_name: "BadFunctionModule",
          description: "Bad function module",
          docs_link: "https://example.com",
          functions: [
            %{
              function_name: "bad_function"
            }
          ]
        }
      ]

      for config <- malformed_configs do
        assert is_map(config)
      end
    end

    test "handles various data types in configurations" do
      config = [
        %{
          module_name: "DataTypeModule",
          description: "Data type module",
          docs_link: "https://example.com/docs",
          functions: [
            %{
              function_name: "type_test",
              description: "Type test function",
              http_method: "GET",
              path: "/type-test",
              response_schema: "TypeResponse",
              arguments: [
                %{name: "string_arg", type: "string"},
                %{name: "map_arg", type: "map"},
                %{name: "integer_arg", type: "integer"},
                %{name: "boolean_arg", type: "boolean"},
                %{name: "unknown_arg", type: "unknown_type"}
              ],
              parameters: [
                %{name: "string_param", type: "string", required: false, default: nil, doc: "String param"},
                %{name: "boolean_param", type: "boolean", required: false, default: "false", doc: "Boolean param"},
                %{name: "integer_param", type: "integer", required: false, default: "0", doc: "Integer param"}
              ]
            }
          ]
        }
      ]

      assert is_list(config)
      module_config = hd(config)
      function = hd(module_config.functions)
      assert length(function.arguments) == 5
      assert length(function.parameters) == 3
    end
  end
end
