defmodule ExOanda.CloseoutUnits do
  @moduledoc """
  Custom Ecto type for representing the position closeout units, which can be
  a float (representing the number of units) or a string ("ALL" or "NONE").
  """

  use Ecto.Type

  @type t :: String.t() | float()

  def type, do: :string

  def cast("ALL"), do: {:ok, "ALL"}
  def cast("NONE"), do: {:ok, "NONE"}
  def cast(value) when is_float(value), do: {:ok, value}
  def cast(_), do: :error

  def load(value) when is_binary(value) and value in ["ALL", "NONE"], do: {:ok, value}
  def load(value) when is_float(value), do: {:ok, value}
  def load(_), do: :error

  def dump("ALL"), do: {:ok, "ALL"}
  def dump("NONE"), do: {:ok, "NONE"}
  def dump(value) when is_float(value), do: {:ok, value}
  def dump(_), do: :error
end
