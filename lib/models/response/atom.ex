defmodule ExOanda.Type.Atom do
  @moduledoc """
  Custom Ecto type for atom.
  """

  use Ecto.Type

  @type t :: atom()

  def type, do: :string

  def cast(value) when is_atom(value), do: {:ok, value}
  def cast(value) when is_binary(value), do: {:ok, String.to_atom(value)}
  def cast(_), do: :error

  def load(value), do: {:ok, String.to_existing_atom(value)}

  def dump(value) when is_atom(value), do: {:ok, Atom.to_string(value)}
  def dump(_), do: :error
end
