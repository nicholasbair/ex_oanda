defmodule ExOanda.InstrumentTest do
  use ExUnit.Case, async: true
  alias ExOanda.Instrument

  describe "changeset/2" do
    test "valid changeset with all fields" do
      params = %{
        name: "EUR_USD",
        type: :CURRENCY,
        display_name: "EUR/USD",
        pip_location: -4,
        display_precision: 5,
        trade_units_precision: 0,
        minimum_trade_size: 1.0,
        maximum_trailing_stop_distance: 10.0,
        minimum_trailing_stop_distance: 0.0001,
        maximum_position_size: 1_000_000.0,
        maximum_order_units: 1_000_000.0,
        margin_rate: 0.02,
        guaranteed_stop_loss_order_mode: :ALLOWED,
        guaranteed_stop_loss_order_premium: 0.0001,
        guaranteed_stop_loss_order_level_restriction: %{
          volume: "1000000",
          price_range: "0.01"
        },
        commission: %{
          commission: "0.0001",
          units_traded: "1000000",
          minimum_commission: "0.50"
        },
        financing: %{
          long_rate: "0.0001",
          short_rate: "-0.0001"
        },
        tags: [
          %{
            type: "CURRENCY",
            name: "EUR_USD"
          }
        ]
      }

      changeset = Instrument.changeset(%Instrument{}, params)

      assert changeset.valid?
      assert changeset.errors == []
    end

    test "valid changeset with minimal fields" do
      params = %{
        name: "EUR_USD",
        type: :CURRENCY,
        display_name: "EUR/USD",
        pip_location: -4,
        display_precision: 5,
        trade_units_precision: 0,
        minimum_trade_size: 1.0,
        maximum_trailing_stop_distance: 10.0,
        minimum_trailing_stop_distance: 0.0001,
        maximum_position_size: 1_000_000.0,
        maximum_order_units: 1_000_000.0,
        margin_rate: 0.02,
        guaranteed_stop_loss_order_mode: :DISABLED,
        guaranteed_stop_loss_order_premium: 0.0
      }

      changeset = Instrument.changeset(%Instrument{}, params)

      assert changeset.valid?
      assert changeset.errors == []
    end

    test "changeset with invalid enum values" do
      params = %{
        name: "EUR_USD",
        type: :INVALID_TYPE,
        display_name: "EUR/USD",
        pip_location: -4,
        display_precision: 5,
        trade_units_precision: 0,
        minimum_trade_size: 1.0,
        maximum_trailing_stop_distance: 10.0,
        minimum_trailing_stop_distance: 0.0001,
        maximum_position_size: 1_000_000.0,
        maximum_order_units: 1_000_000.0,
        margin_rate: 0.02,
        guaranteed_stop_loss_order_mode: :INVALID_MODE,
        guaranteed_stop_loss_order_premium: 0.0
      }

      changeset = Instrument.changeset(%Instrument{}, params)

      refute changeset.valid?
      refute Enum.empty?(changeset.errors)
    end

    test "changeset with valid enum values" do
      valid_types = [:CURRENCY, :CFD, :METAL]
      valid_modes = [:DISABLED, :ALLOWED, :REQUIRED]

      for type <- valid_types do
        params = %{
          name: "TEST_INSTRUMENT",
          type: type,
          display_name: "Test Instrument",
          pip_location: -4,
          display_precision: 5,
          trade_units_precision: 0,
          minimum_trade_size: 1.0,
          maximum_trailing_stop_distance: 10.0,
          minimum_trailing_stop_distance: 0.0001,
          maximum_position_size: 1_000_000.0,
          maximum_order_units: 1_000_000.0,
          margin_rate: 0.02,
          guaranteed_stop_loss_order_mode: :DISABLED,
          guaranteed_stop_loss_order_premium: 0.0
        }

        changeset = Instrument.changeset(%Instrument{}, params)
        assert changeset.valid?, "Type #{type} should be valid"
      end

      for mode <- valid_modes do
        params = %{
          name: "TEST_INSTRUMENT",
          type: :CURRENCY,
          display_name: "Test Instrument",
          pip_location: -4,
          display_precision: 5,
          trade_units_precision: 0,
          minimum_trade_size: 1.0,
          maximum_trailing_stop_distance: 10.0,
          minimum_trailing_stop_distance: 0.0001,
          maximum_position_size: 1_000_000.0,
          maximum_order_units: 1_000_000.0,
          margin_rate: 0.02,
          guaranteed_stop_loss_order_mode: mode,
          guaranteed_stop_loss_order_premium: 0.0
        }

        changeset = Instrument.changeset(%Instrument{}, params)
        assert changeset.valid?, "Mode #{mode} should be valid"
      end
    end
  end
end
