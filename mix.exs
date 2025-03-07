defmodule ExOanda.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_oanda,
      version: "0.0.13",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      dialyzer: [plt_add_apps: [:mix]],
      docs: [
        main: "ExOanda",
        extras: ["README.md"] # TODO add license
      ],
      test_coverage: [tool: ExCoveralls]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:bypass, "~> 2.1", only: :test},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:ecto, "~> 3.11"},
      {:excoveralls, "~> 0.18.1", only: :test},
      {:ex_doc, "~> 0.31", only: :dev, runtime: false},
      {:miss, "~> 0.1.5"},
      {:nested_filter, "~> 1.2"},
      {:nimble_options, "~> 1.1"},
      {:polymorphic_embed, "~> 5.0"},
      {:recase, "~> 0.8.1"},
      {:req, "~> 0.5.2"},
      {:req_telemetry, "~> 0.1.1"},
      {:typed_ecto_schema, "~> 0.4.1", runtime: false},
      {:yaml_elixir, "~> 2.11"}
    ]
  end
end
