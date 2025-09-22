defmodule ExOanda.Type.AtomTest do
  use ExUnit.Case, async: true
  alias ExOanda.Type.Atom

  describe "type/0" do
    test "returns :string" do
      assert Atom.type() == :string
    end
  end

  describe "cast/1" do
    test "returns {:ok, value} when value is an atom" do
      assert Atom.cast(:test_atom) == {:ok, :test_atom}
      assert Atom.cast(:another) == {:ok, :another}
    end

    test "returns {:ok, atom} when value is a binary" do
      assert Atom.cast("test_atom") == {:ok, :test_atom}
      assert Atom.cast("another") == {:ok, :another}
    end

    test "returns :error for invalid values" do
      assert Atom.cast(123) == :error
      assert Atom.cast([]) == :error
      assert Atom.cast(%{}) == :error
    end
  end

  describe "load/1" do
    test "returns {:ok, atom} for string values" do
      :test_load_atom
      assert Atom.load("test_load_atom") == {:ok, :test_load_atom}
    end

    test "raises ArgumentError for non-existing atoms" do
      assert_raise ArgumentError, fn ->
        Atom.load("non_existing_atom_#{System.unique_integer()}")
      end
    end
  end

  describe "dump/1" do
    test "returns {:ok, string} when value is an atom" do
      assert Atom.dump(:test_dump) == {:ok, "test_dump"}
      assert Atom.dump(:another_atom) == {:ok, "another_atom"}
    end

    test "returns :error for non-atom values" do
      assert Atom.dump("string") == :error
      assert Atom.dump(123) == :error
      assert Atom.dump([]) == :error
      assert Atom.dump(%{}) == :error
    end
  end
end
