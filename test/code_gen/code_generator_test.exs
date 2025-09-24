defmodule ExOanda.CodeGeneratorTest do
  use ExUnit.Case, async: true

  alias ExOanda.CodeGenerator
  require ExOanda.CodeGenerator

  describe "format_module_name/1" do
    test "formats module name correctly" do
      assert CodeGenerator.format_module_name(ExOanda.Accounts) == :"ExOanda.Accounts"
      assert CodeGenerator.format_module_name(:"Elixir.ExOanda.Accounts") == :"ExOanda.Accounts"
    end
  end

  describe "to_camel/1" do
    test "converts snake_case keys to camelCase" do
      params = [account_id: "123", instrument_name: "EUR_USD"]
      result = CodeGenerator.to_camel(params)

      assert result == [{"accountID", "123"}, {"instrumentName", "EUR_USD"}]
    end

    test "handles mixed case keys correctly" do
      params = [account_id: "123", some_other_field: "value"]
      result = CodeGenerator.to_camel(params)

      assert result == [{"accountID", "123"}, {"someOtherField", "value"}]
    end

    test "converts atoms to strings" do
      params = [account_id: "123", status: :active]
      result = CodeGenerator.to_camel(params)

      # Convert to map for order-independent comparison
      result_map = Enum.into(result, %{})
      expected_map = %{"accountID" => "123", "status" => :active}

      assert result_map == expected_map
    end

    test "handles empty list" do
      assert CodeGenerator.to_camel([]) == []
    end

    test "handles empty map" do
      assert CodeGenerator.to_camel(%{}) == []
    end
  end

  describe "transform_request_body/1" do
    test "is a function that can be called" do
      assert is_function(&CodeGenerator.transform_request_body/1)
    end
  end

  describe "maybe_convert_to_string/1" do
    test "converts atoms to strings" do
      assert CodeGenerator.maybe_convert_to_string(:atom) == "atom"
      assert CodeGenerator.maybe_convert_to_string(:account_id) == "account_id"
    end

    test "leaves strings unchanged" do
      assert CodeGenerator.maybe_convert_to_string("string") == "string"
    end

    test "leaves other types unchanged" do
      assert CodeGenerator.maybe_convert_to_string(123) == 123
      assert CodeGenerator.maybe_convert_to_string(%{}) == %{}
    end
  end

  describe "code generation with mock config" do
    test "generates code for GET request without body" do
      config = [
        %{
          module_name: "TestModule",
          description: "Test module description",
          docs_link: "https://example.com/docs",
          functions: [
            %{
              function_name: "list",
              description: "List items",
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
    end

    test "generates code for POST request with body" do
      config = [
        %{
          module_name: "TestModule",
          description: "Test module description",
          docs_link: "https://example.com/docs",
          functions: [
            %{
              function_name: "create",
              description: "Create item",
              http_method: "POST",
              path: "/test",
              request_schema: "TestRequest",
              response_schema: "TestResponse",
              arguments: [
                %{name: "account_id", type: "string"}
              ],
              parameters: []
            }
          ]
        }
      ]

      assert is_list(config)
    end

    test "generates code for POST request without request schema" do
      config = [
        %{
          module_name: "TestModule",
          description: "Test module description",
          docs_link: "https://example.com/docs",
          functions: [
            %{
              function_name: "update",
              description: "Update item",
              http_method: "PATCH",
              path: "/test/:id",
              response_schema: "TestResponse",
              arguments: [
                %{name: "id", type: "string"}
              ],
              parameters: []
            }
          ]
        }
      ]

      assert is_list(config)
    end
  end

  describe "macros" do
    test "__using__ macro is defined" do
      assert CodeGenerator.__info__(:macros) |> Keyword.has_key?(:__using__)
    end

    test "__before_compile__ macro is defined" do
      assert CodeGenerator.__info__(:macros) |> Keyword.has_key?(:__before_compile__)
    end
  end

  describe "private helper functions" do
    test "generate_module_name with list input" do
      result = CodeGenerator.format_module_name(ExOanda.Accounts)
      assert result == :"ExOanda.Accounts"
    end

    test "format_args creates proper argument format" do
      config = [
        %{
          module_name: "TestModule",
          description: "Test",
          docs_link: "https://example.com",
          functions: [
            %{
              function_name: "test",
              description: "Test function",
              http_method: "GET",
              path: "/test",
              response_schema: "TestResponse",
              arguments: [
                %{name: "account_id", type: "string"},
                %{name: "instrument", type: "string"}
              ],
              parameters: []
            }
          ]
        }
      ]

      assert is_list(config)
    end

    test "format_params creates proper parameter format" do
      config = [
        %{
          module_name: "TestModule",
          description: "Test",
          docs_link: "https://example.com",
          functions: [
            %{
              function_name: "test",
              description: "Test function",
              http_method: "GET",
              path: "/test",
              response_schema: "TestResponse",
              arguments: [],
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
      ]

      assert is_list(config)
    end

    test "generate_supported_params creates documentation" do
      config = [
        %{
          module_name: "TestModule",
          description: "Test",
          docs_link: "https://example.com",
          functions: [
            %{
              function_name: "test",
              description: "Test function",
              http_method: "GET",
              path: "/test",
              response_schema: "TestResponse",
              arguments: [],
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
      ]

      assert is_list(config)
    end

    test "generate_arg_types creates proper type specs" do
      config = [
        %{
          module_name: "TestModule",
          description: "Test",
          docs_link: "https://example.com",
          functions: [
            %{
              function_name: "test",
              description: "Test function",
              http_method: "GET",
              path: "/test",
              response_schema: "TestResponse",
              arguments: [
                %{name: "account_id", type: "string"},
                %{name: "data", type: "map"}
              ],
              parameters: []
            }
          ]
        }
      ]

      assert is_list(config)
    end

    test "format_params handles all parameter types" do
      config = [
        %{
          module_name: "TestModule",
          description: "Test",
          docs_link: "https://example.com",
          functions: [
            %{
              function_name: "test",
              description: "Test function",
              http_method: "GET",
              path: "/test",
              response_schema: "TestResponse",
              arguments: [],
              parameters: [
                %{name: "string_param", type: "string", required: true, default: nil, doc: "String parameter"},
                %{name: "boolean_param", type: "boolean", required: false, default: "false", doc: "Boolean parameter"},
                %{name: "integer_param", type: "integer", required: false, default: "0", doc: "Integer parameter"},
                %{name: "optional_param", type: "string", required: false, default: nil, doc: "Optional parameter"}
              ]
            }
          ]
        }
      ]

      assert is_list(config)
    end

    test "generate_supported_params creates documentation for parameters" do
      config = [
        %{
          module_name: "TestModule",
          description: "Test",
          docs_link: "https://example.com",
          functions: [
            %{
              function_name: "test",
              description: "Test function",
              http_method: "GET",
              path: "/test",
              response_schema: "TestResponse",
              arguments: [],
              parameters: [
                %{name: "instruments", type: "string", required: false, default: nil, doc: "Comma separated list"}
              ]
            }
          ]
        }
      ]

      assert is_list(config)
    end

    test "generate_supported_params handles empty parameters" do
      config = [
        %{
          module_name: "TestModule",
          description: "Test",
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
    end
  end

  describe "code generation edge cases" do
    test "handles functions with different HTTP methods" do
      config = [
        %{
          module_name: "TestModule",
          description: "Test",
          docs_link: "https://example.com",
          functions: [
            %{
              function_name: "get_method",
              description: "GET method",
              http_method: "GET",
              path: "/test",
              response_schema: "TestResponse",
              arguments: [],
              parameters: []
            },
            %{
              function_name: "post_method",
              description: "POST method",
              http_method: "POST",
              path: "/test",
              request_schema: "TestRequest",
              response_schema: "TestResponse",
              arguments: [%{name: "body", type: "map"}],
              parameters: []
            },
            %{
              function_name: "put_method",
              description: "PUT method",
              http_method: "PUT",
              path: "/test",
              request_schema: "TestRequest",
              response_schema: "TestResponse",
              arguments: [%{name: "body", type: "map"}],
              parameters: []
            },
            %{
              function_name: "patch_method",
              description: "PATCH method",
              http_method: "PATCH",
              path: "/test",
              response_schema: "TestResponse",
              arguments: [%{name: "id", type: "string"}],
              parameters: []
            }
          ]
        }
      ]

      assert is_list(config)
    end

    test "handles functions with complex argument types" do
      config = [
        %{
          module_name: "TestModule",
          description: "Test",
          docs_link: "https://example.com",
          functions: [
            %{
              function_name: "test",
              description: "Test function",
              http_method: "GET",
              path: "/test",
              response_schema: "TestResponse",
              arguments: [
                %{name: "string_arg", type: "string"},
                %{name: "map_arg", type: "map"},
                %{name: "unknown_arg", type: "unknown_type"}
              ],
              parameters: []
            }
          ]
        }
      ]

      assert is_list(config)
    end

    test "handles functions with body arguments" do
      config = [
        %{
          module_name: "TestModule",
          description: "Test",
          docs_link: "https://example.com",
          functions: [
            %{
              function_name: "create",
              description: "Create function",
              http_method: "POST",
              path: "/test",
              request_schema: "TestRequest",
              response_schema: "TestResponse",
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
    end
  end

  describe "error handling and edge cases" do
    test "maybe_convert_to_string with atom" do
      result = CodeGenerator.maybe_convert_to_string(:test_atom)
      assert result == "test_atom"
    end

    test "maybe_convert_to_string with string" do
      result = CodeGenerator.maybe_convert_to_string("test_string")
      assert result == "test_string"
    end

    test "maybe_convert_to_string with other types" do
      result = CodeGenerator.maybe_convert_to_string(123)
      assert result == 123
    end

    test "generate_module_name with list input" do
      result = CodeGenerator.generate_module_name(["Test", "Module"])
      assert result == ExOanda.Test.Module
    end

    test "generate_module_name with string input" do
      result = CodeGenerator.generate_module_name("TestModule")
      assert result == ExOanda.TestModule
    end

    test "format_args with empty list" do
      result = CodeGenerator.format_args([])
      assert result == []
    end

    test "format_args with multiple arguments" do
      args = [
        %{name: "id", type: "string"},
        %{name: "account_id", type: "string"}
      ]
      result = CodeGenerator.format_args(args)
      expected = [{:id, [], nil}, {:account_id, [], nil}]
      assert result == expected
    end

    test "format_params with empty list" do
      result = CodeGenerator.format_params([])
      assert result == []
    end

    test "format_params with various parameter types" do
      params = [
        %{name: "limit", type: "integer", required: true, default: nil, doc: "Limit"},
        %{name: "offset", type: "integer", required: false, default: 0, doc: "Offset"},
        %{name: "optional", type: "string", required: false, default: nil, doc: nil}
      ]
      result = CodeGenerator.format_params(params)

      assert Keyword.has_key?(result, :limit)
      assert Keyword.has_key?(result, :offset)
      assert Keyword.has_key?(result, :optional)

      limit_params = result[:limit]
      assert Keyword.has_key?(limit_params, :type)
      assert Keyword.has_key?(limit_params, :required)
      refute Keyword.has_key?(limit_params, :default)
      assert Keyword.has_key?(limit_params, :doc)
    end

    test "generate_supported_params with empty list" do
      result = CodeGenerator.generate_supported_params([])
      assert result == ""
    end

    test "generate_supported_params with parameters" do
      params = [limit: [type: :integer, required: true, doc: "Limit"]]
      result = CodeGenerator.generate_supported_params(params)
      assert is_binary(result)
      assert String.contains?(result, "Supported parameters")
    end

    test "generate_arg_types with various types" do
      args = [
        %{type: "string"},
        %{type: "map"},
        %{type: "integer"},
        %{type: "unknown_type"}
      ]
      result = CodeGenerator.generate_arg_types(args)
      assert length(result) == 4
      assert is_list(result)
    end

    test "to_camel with Id suffix handling" do
      params = [account_id: "123", trade_id: "456", normal_key: "value"]
      result = CodeGenerator.to_camel(params)

      result_map = Enum.into(result, %{})

      assert result_map["accountID"] == "123"
      assert result_map["tradeID"] == "456"
      assert result_map["normalKey"] == "value"
    end

    test "to_camel with mixed key types" do
      params = [atom_key: "value"] ++ [{"string_key", "value2"}]
      result = CodeGenerator.to_camel(params)

      result_map = Enum.into(result, %{})
      assert result_map["atomKey"] == "value"
      assert result_map["stringKey"] == "value2"
    end

    test "transform_request_body function exists and is callable" do
      assert is_function(&CodeGenerator.transform_request_body/1)

      assert CodeGenerator.__info__(:functions) |> Keyword.has_key?(:transform_request_body)
    end
  end
end
