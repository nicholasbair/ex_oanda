defmodule ExOandaTest.GeneratedFunctions do
  use ExUnit.Case, async: true

  ExOanda.Config.load_config()
  |> Map.get(:interfaces)
  |> ExOanda.TestGenerator.generate_tests()
end
