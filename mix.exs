defmodule ExOanda.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_oanda,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      description: "Unofficial Elixir SDK for the Oanda API.",
      package: package(),
      name: "ExOanda",
      source_url: url(),
      homepage_url: url(),
      deps: deps(),
      dialyzer: [plt_add_apps: [:mix]],
      docs: [
        main: "ExOanda",
        extras: ["README.md", "LICENSE"],
        groups_for_modules: [
          "API Interfaces": [
            ExOanda.Accounts,
            ExOanda.Orders,
            ExOanda.Trades,
            ExOanda.Positions,
            ExOanda.Pricing,
            ExOanda.Instruments,
            ExOanda.Transactions
          ],
          "Requests": ~r/^ExOanda\.(Request|CloseOutUnits)/,
          "Responses": ~r/^ExOanda\.(Response|Atom)/,
          "Data Models": ~r/^ExOanda\.(Account|Order|Trade|Position|Transaction|Instrument|Pricing|Candlestick|ClientPrice|HomeConversions|PriceBucket|Financing|GuaranteedStopLoss|Instrument|Tag|Calculated|Dynamic|Trade|StopLoss|TakeProfit|TrailingStopLoss|Transfer|Daily|Dividend|Delayed|Fixed|Limit|Market|Margin|Order|Reopen|Reset|ClientConfigure|Close|Create|GuaranteedStopLossOrder|OrderFill|OrderReject|OrderCancel|OrderClientExtensions|TradeClientExtensions|TransferFunds|ClientExtensions)/,
          "Core": [
            ExOanda.Connection
          ],
          "Streaming": [
            ExOanda.Streaming
          ],
          "Errors": ~r/^ExOanda\.(APIError|ValidationError|TransportError|HTTPStatus)/,
          "Utilities": ~r/^ExOanda\.(API|Transform|Type)/
        ],
        groups_for_docs: [
          "API Calls": &(&1[:group] == :api),
          "Data Access": &(&1[:group] == :data)
        ],
        nest_modules_by_prefix: [
          ExOanda.Accounts,
          ExOanda.Orders,
          ExOanda.Trades,
          ExOanda.Positions,
          ExOanda.Pricing,
          ExOanda.Instruments,
          ExOanda.Transactions
        ]
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
      {:recase, "~> 0.9.0"},
      {:req, "~> 0.5.2"},
      {:req_telemetry, "~> 0.1.1"},
      {:telemetry_test, "~> 0.1.0", only: :test},
      {:typed_ecto_schema, "~> 0.4.1", runtime: false},
      {:yaml_elixir, "~> 2.11"}
    ]
  end

  defp package do
    [
      name: "ex_oanda",
      licenses: ["MIT"],
      files: ~w(lib config.yml mix.exs README.md LICENSE CHANGELOG.md),
      links: %{
        github: url(),
        changelog: "#{url()}/blob/main/CHANGELOG.md"
      }
    ]
  end

  defp url, do: "https://github.com/nicholasbair/ex_oanda"
end
