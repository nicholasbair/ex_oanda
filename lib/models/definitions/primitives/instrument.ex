defmodule ExOanda.Instrument do
  @moduledoc """
  Schema for Oanda instrument.
  """

  use TypedEctoSchema
  import Ecto.Changeset
  alias ExOanda.{
    GuaranteedStopLossOrderLevelRestriction,
    InstrumentCommission,
    InstrumentFinancing,
    Tag
  }

  @primary_key false

  typed_embedded_schema do
    field(:name, :string)
    field(:type, Ecto.Enum, values: [:CURRENCY, :CFD, :METAL])
    field(:display_name, :string)
    field(:pip_location, :integer)
    field(:display_precision, :integer)
    field(:trade_units_precision, :integer)
    field(:minimum_trade_size, :float)
    field(:maximum_trailing_stop_distance, :float)
    field(:minimum_trailing_stop_distance, :float)
    field(:maximum_position_size, :float)
    field(:maximum_order_units, :float)
    field(:margin_rate, :float)
    field(:guaranteed_stop_loss_order_mode, Ecto.Enum, values: [:DISABLED, :ALLOWED, :REQUIRED])
    field(:guaranteed_stop_loss_order_premium, :float)

    embeds_one :guaranteed_stop_loss_order_level_restriction, GuaranteedStopLossOrderLevelRestriction
    embeds_one :commission, InstrumentCommission
    embeds_one :financing, InstrumentFinancing
    embeds_many :tags, Tag
  end

  @doc false
  def changeset(struct, params) do
    struct
    |> cast(params, [
      :name, :type, :display_name, :pip_location, :display_precision, :trade_units_precision,
      :minimum_trade_size, :maximum_trailing_stop_distance, :minimum_trailing_stop_distance,
      :maximum_position_size, :maximum_order_units, :margin_rate, :guaranteed_stop_loss_order_mode,
      :guaranteed_stop_loss_order_premium
    ])
    |> cast_embed(:guaranteed_stop_loss_order_level_restriction)
    |> cast_embed(:commission)
    |> cast_embed(:financing)
    |> cast_embed(:tags)
  end
end
