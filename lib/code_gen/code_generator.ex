defmodule ExOanda.CodeGenerator do
  @moduledoc false

  alias ExOanda.{
    APIError,
    Config,
    DecodeError,
    TransportError,
    ValidationError
  }

  defmacro __using__(_opts) do
    quote do
      @before_compile ExOanda.CodeGenerator
    end
  end

  defmacro __before_compile__(_env) do
    config =
      case Mix.env() do
        :test -> load_test_config()
        _ -> Config.load_config()
      end

    config
    |> generate_code()
  end

  defp generate_code(config) do
    interface_modules = Enum.map(config, fn %{module_name: name, description: desc, docs_link: docs_link, functions: funcs} ->
      module_name = generate_module_name(name)

      quote do
        unless Code.ensure_loaded?(unquote(module_name)) do
          defmodule unquote(module_name) do
            @moduledoc """
            #{unquote(desc)}

            ## Docs
            - [Oanda Docs](#{unquote(docs_link)})
            """
            alias ExOanda.API
            alias ExOanda.Connection, as: Conn
            alias ExOanda.Response, as: Res
            unquote_splicing(generate_functions(funcs, docs_link))
          end
        end
      end
    end)

    test_modules =
      case Mix.env() do
        :test -> generate_test_modules(config)
        _ -> []
      end

    interface_modules ++ test_modules
  end

  defp generate_test_modules(config) do
    Enum.map(config, fn %{module_name: name, functions: funcs} ->
      test_module_name = Module.concat([ExOandaTest, name, "Generated"])
      interface_module_name = generate_module_name(name)

      quote do
        unless Code.ensure_loaded?(unquote(test_module_name)) do
          defmodule unquote(test_module_name) do
            use ExUnit.Case, async: true
            unquote_splicing(generate_test_functions(funcs, interface_module_name))
          end
        end
      end
    end)
  end

  defp generate_test_functions(functions, interface_module_name) do
    Enum.flat_map(functions, fn function ->
      function_name = function.function_name
      arity = length(function.arguments) + 1

      [
        quote do
          test "#{unquote(interface_module_name)}.#{unquote(function_name)} is generated." do
            Code.ensure_loaded(unquote(interface_module_name))
            function_name_atom = unquote(String.to_atom(function_name))
            assert function_exported?(
              unquote(interface_module_name),
              function_name_atom,
              unquote(arity)
            )
          end
        end,
        quote do
          test "#{unquote(interface_module_name)}.#{unquote(function_name)}! is generated." do
            Code.ensure_loaded(unquote(interface_module_name))
            bang_function_name = unquote(String.to_atom("#{function_name}!"))
            assert function_exported?(
              unquote(interface_module_name),
              bang_function_name,
              unquote(arity)
            )
          end
        end
      ]
    end)
  end

  defp generate_functions(functions, docs_link) do
    Enum.map(functions, &generate_function(&1, docs_link))
  end

  defp generate_function(%{http_method: method, request_schema: req} = config, docs_link)
       when method in ["POST", "PUT", "PATCH"] and is_nil(req) do
    %{
      function_name: name,
      description: desc,
      http_method: method,
      path: path,
      arguments: args,
      parameters: parameters,
      response_schema: response_schema
    } = config
    formatted_args = format_args(args)
    arg_names = Enum.map(args, & &1.name)
    formatted_params = format_params(parameters)
    supported_params = generate_supported_params(formatted_params)
    arg_types = generate_arg_types(args)
    response_model = generate_module_name([Response, response_schema])

    quote do
      @doc"""
      #{unquote(desc)}

      ## Examples

          iex> {:ok, res} = #{ExOanda.CodeGenerator.format_module_name(__MODULE__)}.#{unquote(name)}(conn, #{
            Enum.map_join(unquote(arg_names), ", ", &"#{&1}")
          })
      #{unquote(supported_params)}
      ## Docs
      - [Oanda Docs](#{unquote(docs_link)})
      """
      @spec unquote(String.to_atom(name))(
              Conn.t(),
              unquote_splicing(arg_types),
              Keyword.t()
            ) :: {:ok, Res.t(unquote(response_model).t())} |
                  {:error, Res.t() | ValidationError.t() | TransportError.t() | DecodeError.t()}
      def unquote(String.to_atom(name))(%Conn{} = conn, unquote_splicing(formatted_args), params \\ []) do
        path_params =
          unquote(arg_names)
          |> Enum.map(&String.to_atom/1)
          |> Enum.filter(fn k -> k != :body end)
          |> Enum.zip(unquote(formatted_args))

        case NimbleOptions.validate(params, unquote(formatted_params)) do
          {:ok, _} ->
            Req.new(
              auth: API.auth_bearer(conn),
              url: conn.api_server <> unquote(path),
              path_params: path_params,
              method: unquote(method),
              headers: API.base_headers(),
              params: params
            )
            |> API.maybe_attach_telemetry(conn)
            |> Req.request(conn.options)
            |> API.handle_response(unquote(response_model))

          {:error, %NimbleOptions.ValidationError{} = validation_error} ->
            {:error, ValidationError.exception(validation_error)}
        end
      end

      @doc"""
      #{unquote(ExOanda.CodeGenerator.format_bang_description(desc))}

      ## Examples

          iex> res = #{ExOanda.CodeGenerator.format_module_name(__MODULE__)}.#{unquote(name)}!(conn, #{
            Enum.map_join(unquote(arg_names), ", ", &"#{&1}")
          })
      #{unquote(supported_params)}
      ## Docs
      - [Oanda Docs](#{unquote(docs_link)})
      """
      @spec unquote(String.to_atom("#{name}!"))(
              Conn.t(),
              unquote_splicing(arg_types),
              Keyword.t()
            ) :: Res.t(unquote(response_model).t())
      def unquote(String.to_atom("#{name}!"))(%Conn{} = conn, unquote_splicing(formatted_args), params \\ []) do
        case unquote(String.to_atom(name))(conn, unquote_splicing(formatted_args), params) do
          {:ok, res} -> res
          {:error, %ValidationError{} = validation_error} -> raise validation_error
          {:error, %TransportError{} = transport_error} -> raise transport_error
          {:error, %DecodeError{} = decode_error} -> raise decode_error
          {:error, reason} -> raise APIError, reason
        end
      end
    end
  end

  defp generate_function(%{http_method: method} = config, docs_link)
       when method in ["POST", "PUT", "PATCH"] do
    %{
      function_name: name,
      description: desc,
      http_method: method,
      path: path,
      arguments: args,
      parameters: parameters,
      response_schema: response_schema,
      request_schema: request_schema
    } = config
    formatted_args = format_args(args)
    arg_names = Enum.map(args, & &1.name)
    formatted_params = format_params(parameters)
    supported_params = generate_supported_params(formatted_params)
    arg_types = generate_arg_types(args)
    response_model = generate_module_name([Response, response_schema])
    request_model = generate_module_name([Request, request_schema])

    quote do
      @doc"""
      #{unquote(desc)}

      ## Examples

          iex> {:ok, res} = #{ExOanda.CodeGenerator.format_module_name(__MODULE__)}.#{unquote(name)}(conn, #{
            Enum.map_join(unquote(arg_names), ", ", &"#{&1}")
          })
      #{unquote(supported_params)}
      ## Docs
      - [Oanda Docs](#{unquote(docs_link)})
      """
      @spec unquote(String.to_atom(name))(
              Conn.t(),
              unquote_splicing(arg_types),
              Keyword.t()
            ) :: {:ok, Res.t(unquote(response_model).t())} |
                  {:error, Res.t() | ValidationError.t() | TransportError.t() | DecodeError.t()}
      def unquote(String.to_atom(name))(%Conn{} = conn, unquote_splicing(formatted_args), params \\ []) do
        path_params =
          unquote(arg_names)
          |> Enum.map(&String.to_atom/1)
          |> Enum.filter(fn k -> k != :body end)
          |> Enum.zip(unquote(formatted_args))

        body = binding()[:body] || %{}

        validated_body =
          unquote(request_model).changeset(unquote(request_model).__struct__(), body)
          |> Ecto.Changeset.apply_action(:validate)

        case validated_body do
          {:error, err} ->
            {:error, err}

          {:ok, body} ->
            case NimbleOptions.validate(params, unquote(formatted_params)) do
              {:ok, _} ->
                Req.new(
                  auth: API.auth_bearer(conn),
                  url: conn.api_server <> unquote(path),
                  path_params: path_params,
                  method: unquote(method),
                  headers: API.base_headers(),
                  params: params,
                  json: ExOanda.CodeGenerator.transform_request_body(body)
                )
                |> API.maybe_attach_telemetry(conn)
                |> Req.request(conn.options)
                |> API.handle_response(unquote(response_model))

              {:error, %NimbleOptions.ValidationError{} = validation_error} ->
                {:error, ValidationError.exception(validation_error)}
            end
        end
      end

      @doc"""
      #{unquote(ExOanda.CodeGenerator.format_bang_description(desc))}

      ## Examples

          iex> res = #{ExOanda.CodeGenerator.format_module_name(__MODULE__)}.#{unquote(name)}!(conn, #{
            Enum.map_join(unquote(arg_names), ", ", &"#{&1}")
          })
      #{unquote(supported_params)}
      ## Docs
      - [Oanda Docs](#{unquote(docs_link)})
      """
      @spec unquote(String.to_atom("#{name}!"))(
              Conn.t(),
              unquote_splicing(arg_types),
              Keyword.t()
            ) :: Res.t(unquote(response_model).t())
      def unquote(String.to_atom("#{name}!"))(%Conn{} = conn, unquote_splicing(formatted_args), params \\ []) do
        case unquote(String.to_atom(name))(conn, unquote_splicing(formatted_args), params) do
          {:ok, res} -> res
          {:error, %ValidationError{} = validation_error} -> raise validation_error
          {:error, %TransportError{} = transport_error} -> raise transport_error
          {:error, %DecodeError{} = decode_error} -> raise decode_error
          {:error, reason} -> raise APIError, reason
        end
      end
    end
  end

  defp generate_function(config, docs_link) do
    %{
      function_name: name,
      description: desc,
      http_method: method,
      path: path,
      arguments: args,
      parameters: parameters,
      response_schema: response_schema
    } = config
    formatted_args = format_args(args)
    arg_names = Enum.map(args, & &1.name)
    formatted_params = format_params(parameters)
    supported_params = generate_supported_params(formatted_params)
    arg_types = generate_arg_types(args)
    response_model = generate_module_name([Response, response_schema])

    quote do
      @doc"""
      #{unquote(desc)}

      ## Examples

          iex> {:ok, res} = #{ExOanda.CodeGenerator.format_module_name(__MODULE__)}.#{unquote(name)}(conn, #{
            Enum.map_join(unquote(arg_names), ", ", &"#{&1}")
          })
      #{unquote(supported_params)}
      ## Docs
      - [Oanda Docs](#{unquote(docs_link)})
      """
      @spec unquote(String.to_atom(name))(
              Conn.t(),
              unquote_splicing(arg_types),
              Keyword.t()
            ) :: {:ok, Res.t(unquote(response_model).t())} |
                  {:error, Res.t() | ValidationError.t() | TransportError.t() | DecodeError.t()}
      def unquote(String.to_atom(name))(%Conn{} = conn, unquote_splicing(formatted_args), params \\ []) do
        path_params =
          unquote(arg_names)
          |> Enum.map(&String.to_atom/1)
          |> Enum.zip(unquote(formatted_args))

        case NimbleOptions.validate(params, unquote(formatted_params)) do
          {:ok, _} ->
            Req.new(
              auth: API.auth_bearer(conn),
              url: conn.api_server <> unquote(path),
              path_params: path_params,
              method: unquote(method),
              headers: API.base_headers(),
              params: ExOanda.CodeGenerator.to_camel(params)
            )
            |> API.maybe_attach_telemetry(conn)
            |> Req.request(conn.options)
            |> API.handle_response(unquote(response_model))

          {:error, %NimbleOptions.ValidationError{} = validation_error} ->
            {:error, ValidationError.exception(validation_error)}
        end
      end

      @doc"""
      #{unquote(ExOanda.CodeGenerator.format_bang_description(desc))}

      ## Examples

          iex> res = #{ExOanda.CodeGenerator.format_module_name(__MODULE__)}.#{unquote(name)}!(conn, #{
            Enum.map_join(unquote(arg_names), ", ", &"#{&1}")
          })
      #{unquote(supported_params)}
      ## Docs
      - [Oanda Docs](#{unquote(docs_link)})
      """
      @spec unquote(String.to_atom("#{name}!"))(
              Conn.t(),
              unquote_splicing(arg_types),
              Keyword.t()
            ) :: Res.t(unquote(response_model).t())
      def unquote(String.to_atom("#{name}!"))(%Conn{} = conn, unquote_splicing(formatted_args), params \\ []) do
        case unquote(String.to_atom(name))(conn, unquote_splicing(formatted_args), params) do
          {:ok, res} -> res
          {:error, %ValidationError{} = validation_error} -> raise validation_error
          {:error, %TransportError{} = transport_error} -> raise transport_error
          {:error, %DecodeError{} = decode_error} -> raise decode_error
          {:error, reason} -> raise APIError, reason
        end
      end
    end
  end

  @doc false
  def format_module_name(module_name) do
    module_name
    |> Atom.to_string()
    |> String.replace("Elixir.", "")
    |> String.to_atom()
  end

  @doc false
  def to_camel(params) do
    params
    |> Enum.into(%{})
    |> Recase.Enumerable.convert_keys(&Recase.to_camel/1)
    |> Enum.map(fn {k, v} ->
      k = maybe_convert_to_string(k)

      case String.ends_with?(k, "Id") do
        true -> {String.replace(k, "Id", "ID"), v}
        false -> {k, v}
      end
    end)
  end

  @doc false
  def transform_request_body(body) do
    body
    |> Miss.Map.from_nested_struct()
    |> to_camel()
    |> Enum.into(%{})
    |> NestedFilter.drop_by_value([nil])
  end

  @doc false
  def maybe_convert_to_string(val) when is_atom(val), do: Atom.to_string(val)
  def maybe_convert_to_string(val), do: val

  @doc false
  def generate_module_name(input) when is_list(input), do: Module.concat([ExOanda] ++ input)
  def generate_module_name(input), do: Module.concat([ExOanda, input])

  @doc false
  def format_bang_description(desc) when is_binary(desc) do
    desc
    |> String.trim_trailing(".")
    |> Kernel.<>(", raising an exception on error.")
  end

  def format_bang_description(nil), do: ""

  @doc false
  def format_args(args) do
    for %{name: name} <- args, do: {String.to_atom(name), [], nil}
  end

  @doc false
  def format_params(params) do
    Enum.reduce(params, [], fn %{name: name, type: type, required: required, default: default, doc: doc}, acc ->
      params_list = [
        type: String.to_atom(type),
        required: required,
        default: default,
        doc: doc
      ]

      filtered_params = Enum.reject(params_list, fn {_, value} -> is_nil(value) end)
      Keyword.put(acc, String.to_atom(name), filtered_params)
    end)
  end

  @doc false
  def generate_supported_params([]), do: ""
  def generate_supported_params(formatted_params) do
    """

    ## Supported parameters
    #{NimbleOptions.docs(formatted_params)}

    """
  end

  @doc false
  def generate_arg_types(args) do
    Enum.map(args, fn %{type: type} ->
      case type do
        "string" -> quote do: String.t()
        "map" -> quote do: map()
        _ -> quote do: any()
      end
    end)
  end

  @doc false
  def load_test_config do
    [
      %{
        module_name: "TestAccounts",
        description: "Test accounts interface for testing",
        docs_link: "https://example.com/test-docs",
        functions: [
          %{
            function_name: "list",
            description: "List test accounts",
            http_method: "GET",
            path: "/test-accounts",
            response_schema: "ListAccounts",
            arguments: [],
            parameters: []
          },
          %{
            function_name: "find",
            description: "Find test account",
            http_method: "GET",
            path: "/test-accounts/:id",
            response_schema: "FindAccount",
            arguments: [%{name: "id", type: "string"}],
            parameters: []
          }
        ]
      },
      %{
        module_name: "TestOrders",
        description: "Test orders interface for testing",
        docs_link: "https://example.com/test-docs",
        functions: [
          %{
            function_name: "list",
            description: "List test orders",
            http_method: "GET",
            path: "/test-orders",
            response_schema: "ListOrders",
            arguments: [%{name: "account_id", type: "string"}],
            parameters: []
          }
        ]
      }
    ]
  end
end
