defmodule ExOanda.CodeGenerator do
  @moduledoc false

  alias ExOanda.Config

  defmacro __using__(_opts) do
    quote do
      @before_compile ExOanda.CodeGenerator
    end
  end

  defmacro __before_compile__(_env) do
    Config.load_config()
    |> generate_code()
  end

  defp generate_code(config) do
    Enum.map(config, fn %{module_name: name, description: desc, functions: funcs} ->
      quote do
        defmodule unquote(generate_module_name(name)) do
          @moduledoc """
          #{unquote(desc)}
          """
          alias ExOanda.API
          alias ExOanda.Connection, as: Conn
          unquote_splicing(generate_functions(funcs))
        end
      end
    end)
  end

  defp generate_functions(functions), do: Enum.map(functions, &generate_function/1)

  defp generate_function(%{http_method: method} = config) when method in ["POST", "PUT", "PATCH"] do
    %{function_name: name, description: desc, http_method: method, path: path, arguments: args, parameters: parameters} = config
    formatted_args = format_args(args)
    formatted_params = format_params(parameters)
    arg_types = generate_arg_types(args)

    quote do
      @doc"""
      #{unquote(desc)}

      ## Examples

          iex> {:ok, res} = #{ExOanda.CodeGenerator.format_module_name(__MODULE__)}.#{unquote(name)}(conn, #{Enum.map_join(unquote(args), ", ", &"#{&1}")})

      ## Supported parameters
      #{NimbleOptions.docs(unquote(formatted_params))}
      """
      @spec unquote(String.to_atom(name))(Conn.t(), unquote_splicing(arg_types), Keyword.t()) :: {:ok, map()} | {:error, map()}
      def unquote(String.to_atom(name))(%Conn{} = conn, unquote_splicing(formatted_args), params \\ []) do
        path_params =
          unquote(args)
          |> Enum.map(&String.to_atom/1)
          |> Enum.filter(fn k -> k != :body end)
          |> Enum.zip(unquote(formatted_args))

        body = binding()[:body] || %{}

        case NimbleOptions.validate(params, unquote(formatted_params)) do
          {:ok, _} ->
            Req.new(
              auth: API.auth_bearer(conn),
              url: conn.api_server <> unquote(path),
              path_params: path_params,
              method: unquote(method),
              headers: API.base_headers(),
              params: params,
              json: body
            )
            |> API.maybe_attach_telemetry(conn)
            |> Req.request(conn.options)
            |> API.handle_response()

          {:error, reason} ->
            {:error, reason}
        end
      end

      @doc"""
      #{unquote(desc)}

      ## Examples

          iex> res = #{ExOanda.CodeGenerator.format_module_name(__MODULE__)}.#{unquote(name)}!(conn, #{Enum.map_join(unquote(args), ", ", &"#{&1}")})

      ## Supported parameters
      #{NimbleOptions.docs(unquote(formatted_params))}
      """
      @spec unquote(String.to_atom("#{name}!"))(Conn.t(), unquote_splicing(arg_types), Keyword.t()) :: map()
      def unquote(String.to_atom("#{name}!"))(%Conn{} = conn, unquote_splicing(formatted_args), params \\ []) do
        case unquote(String.to_atom(name))(conn, unquote_splicing(formatted_args), params) do
          {:ok, res} -> res
          {:error, reason} -> raise ExOandaError, reason
        end
      end
    end
  end

  defp generate_function(config) do
    %{function_name: name, description: desc, http_method: method, path: path, arguments: args, parameters: parameters, response_schema: response_schema} = config
    formatted_args = format_args(args)
    formatted_params = format_params(parameters)
    arg_types = generate_arg_types(args)
    model = generate_module_name(response_schema)

    quote do
      @doc"""
      #{unquote(desc)}

      ## Examples

          iex> {:ok, res} = #{ExOanda.CodeGenerator.format_module_name(__MODULE__)}.#{unquote(name)}(conn, #{Enum.map_join(unquote(args), ", ", &"#{&1}")})

      ## Supported parameters
      #{NimbleOptions.docs(unquote(formatted_params))}
      """
      @spec unquote(String.to_atom(name))(Conn.t(), unquote_splicing(arg_types), Keyword.t()) :: {:ok, map()} | {:error, map()}
      def unquote(String.to_atom(name))(%Conn{} = conn, unquote_splicing(formatted_args), params \\ []) do
        path_params =
          unquote(args)
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
              params: ExOanda.CodeGenerator.convert_params(params)
            )
            |> API.maybe_attach_telemetry(conn)
            |> Req.request(conn.options)
            |> API.handle_response(unquote(model))

          {:error, reason} ->
            {:error, reason}
        end
      end

      @doc"""
      #{unquote(desc)}

      ## Examples

          iex> res = #{ExOanda.CodeGenerator.format_module_name(__MODULE__)}.#{unquote(name)}!(conn, #{Enum.map_join(unquote(args), ", ", &"#{&1}")})

      ## Supported parameters
      #{NimbleOptions.docs(unquote(formatted_params))}
      """
      @spec unquote(String.to_atom("#{name}!"))(Conn.t(), unquote_splicing(arg_types), Keyword.t()) :: map()
      def unquote(String.to_atom("#{name}!"))(%Conn{} = conn, unquote_splicing(formatted_args), params \\ []) do
        case unquote(String.to_atom(name))(conn, unquote_splicing(formatted_args), params) do
          {:ok, res} -> res
          {:error, reason} -> raise ExOandaError, reason
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
  def convert_params(params) do
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

  def maybe_convert_to_string(val) when is_atom(val), do: Atom.to_string(val)
  def maybe_convert_to_string(val), do: val

  defp generate_module_name(module_name), do: Module.concat([ExOanda, module_name])

  defp format_args(args) do
    for a <- args, do: {String.to_atom(a), [], nil}
  end

  defp format_params(params) do
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

  defp generate_arg_types(args) do
    Enum.map(args, fn arg_name ->
      case arg_name do
        "account_id" -> quote do: String.t()
        "body" -> quote do: map()
        _ -> quote do: any()
      end
    end)
  end
end
