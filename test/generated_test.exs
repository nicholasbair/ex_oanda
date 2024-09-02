defmodule ExOandaTest.GeneratedFunctions do
  use ExUnit.Case, async: true

  ExOanda.TestGenerator.generate_tests(ExOanda.Config.load_config())
end
