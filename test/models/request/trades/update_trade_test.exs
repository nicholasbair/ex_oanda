defmodule ExOanda.Request.UpdateTradeTest do
  use ExUnit.Case, async: true

  alias ExOanda.Request.UpdateTrade

  describe "changeset/2" do
    test "changeset with empty params should add validation error" do
      params = %{}

      changeset = UpdateTrade.changeset(%UpdateTrade{}, params)

      assert changeset.errors[:take_profit] == {"at least one of [:take_profit, :stop_loss, :trailing_stop_loss, :guaranteed_stop_loss] must be present", []}
      refute changeset.valid?
    end

    test "changeset with nil values should add validation error" do
      params = %{
        take_profit: nil,
        stop_loss: nil,
        trailing_stop_loss: nil,
        guaranteed_stop_loss: nil
      }

      changeset = UpdateTrade.changeset(%UpdateTrade{}, params)

      assert changeset.errors[:take_profit] == {"at least one of [:take_profit, :stop_loss, :trailing_stop_loss, :guaranteed_stop_loss] must be present", []}
      refute changeset.valid?
    end

    test "changeset with take_profit only should pass validation" do
      params = %{
        take_profit: %{
          price: "1.2000",
          time_in_force: "GTC"
        }
      }

      changeset = UpdateTrade.changeset(%UpdateTrade{}, params)

      assert changeset.valid?
      assert changeset.errors == []
    end

    test "changeset with stop_loss only should pass validation" do
      params = %{
        stop_loss: %{
          price: "1.1000",
          time_in_force: "GTC"
        }
      }

      changeset = UpdateTrade.changeset(%UpdateTrade{}, params)

      assert changeset.valid?
      assert changeset.errors == []
    end

    test "changeset with trailing_stop_loss only should pass validation" do
      params = %{
        trailing_stop_loss: %{
          distance: "0.0100",
          time_in_force: "GTC"
        }
      }

      changeset = UpdateTrade.changeset(%UpdateTrade{}, params)

      assert changeset.valid?
      assert changeset.errors == []
    end

    test "changeset with guaranteed_stop_loss only should pass validation" do
      params = %{
        guaranteed_stop_loss: %{
          price: "1.1000",
          time_in_force: "GTC"
        }
      }

      changeset = UpdateTrade.changeset(%UpdateTrade{}, params)

      assert changeset.valid?
      assert changeset.errors == []
    end

    test "changeset with multiple fields should pass validation" do
      params = %{
        take_profit: %{
          price: "1.2000",
          time_in_force: "GTC"
        },
        stop_loss: %{
          price: "1.1000",
          time_in_force: "GTC"
        }
      }

      changeset = UpdateTrade.changeset(%UpdateTrade{}, params)

      assert changeset.valid?
      assert changeset.errors == []
    end

    test "changeset with all fields should pass validation" do
      params = %{
        take_profit: %{
          price: "1.2000",
          time_in_force: "GTC"
        },
        stop_loss: %{
          price: "1.1000",
          time_in_force: "GTC"
        },
        trailing_stop_loss: %{
          distance: "0.0100",
          time_in_force: "GTC"
        },
        guaranteed_stop_loss: %{
          price: "1.1000",
          time_in_force: "GTC"
        }
      }

      changeset = UpdateTrade.changeset(%UpdateTrade{}, params)

      assert changeset.valid?
      assert changeset.errors == []
    end
  end
end
