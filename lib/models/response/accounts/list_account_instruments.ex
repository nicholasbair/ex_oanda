defmodule ExOanda.AccountInstruments do
  @moduledoc """
  Schema for Oanda list account instruments response.
  """

  use TypedEctoSchema
  import Ecto.Changeset

  @primary_key false

  typed_embedded_schema do
    embeds_many :instruments, Instrument, primary_key: false do
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
      field(:commission, :float)

      embeds_many :tags, Tag, primary_key: false do
        field(:type, :string)
        field(:name, :string)
      end

      embeds_one :financing, Financing, primary_key: false do
        field(:long_rate, :float)
        field(:short_rate, :float)

        embeds_many :financing_days_of_week, FinancingDay, primary_key: false do
          field(:day_of_week, Ecto.Enum, values: [:SUNDAY, :MONDAY, :TUESDAY, :WEDNESDAY, :THURSDAY, :FRIDAY, :SATURDAY])
          field(:days_charged, :integer)
        end
      end
    end

    field(:last_transaction_id, :string)
  end

  @doc false
  def changeset(struct, params) do
    struct
    |> cast(params, [:last_transaction_id])
    |> cast_embed(:instruments, with: &instrument_changeset/2)
  end

  defp instrument_changeset(struct, params) do
    struct
    |> cast(params, [
      :name, :type, :display_name, :pip_location, :display_precision, :trade_units_precision,
      :minimum_trade_size, :maximum_trailing_stop_distance, :minimum_trailing_stop_distance,
      :maximum_position_size, :maximum_order_units, :margin_rate, :guaranteed_stop_loss_order_mode,
      :commission
    ])
    |> validate_required([
      :name, :type, :display_name, :pip_location, :display_precision, :trade_units_precision,
      :minimum_trade_size, :maximum_trailing_stop_distance, :minimum_trailing_stop_distance,
      :maximum_position_size, :maximum_order_units, :margin_rate, :guaranteed_stop_loss_order_mode
    ])
    |> cast_embed(:tags, with: &tag_changeset/2)
    |> cast_embed(:financing, with: &financing_changeset/2)
  end

  defp tag_changeset(struct, params) do
    struct
    |> cast(params, [:type, :name])
    |> validate_required([:type, :name])
  end

  defp financing_changeset(struct, params) do
    struct
    |> cast(params, [:long_rate, :short_rate])
    |> validate_required([:long_rate, :short_rate])
    |> cast_embed(:financing_days_of_week, with: &financing_day_changeset/2)
  end

  defp financing_day_changeset(struct, params) do
    struct
    |> cast(params, [:day_of_week, :days_charged])
    |> validate_required([:day_of_week, :days_charged])
  end
end
