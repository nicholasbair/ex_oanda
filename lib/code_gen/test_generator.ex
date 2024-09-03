defmodule ExOanda.TestGenerator do
  @moduledoc false

  use ExUnit.Case, async: true

  def generate_tests(configs) do
    Enum.each(configs, fn %{module_name: module_name, functions: functions} ->
      module = Module.concat([ExOandaTest, module_name, "Generated"])

      test_functions =
        Enum.map(functions, fn function ->
          function_name = function.function_name
          target_module = Module.concat([ExOanda, module_name])
          arity = length(function.arguments) + 1 # Connection struct + configured arguments (less optional params)

          quote do
            test "#{unquote(module_name)}.#{unquote(function_name)} is generated." do
              assert function_exported?(unquote(target_module), unquote(String.to_atom(function_name)), unquote(arity))
            end

            test "#{unquote(module_name)}.#{unquote(function_name)}! is generated." do
              assert function_exported?(unquote(target_module), unquote(String.to_atom("#{function_name}!")), unquote(arity))
            end
          end
        end)

      module_body =
        quote do
          use ExUnit.Case, async: true
          unquote_splicing(test_functions)
        end

      Module.create(module, module_body, __ENV__)
    end)
  end
end
