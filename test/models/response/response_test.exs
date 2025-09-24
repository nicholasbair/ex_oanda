defmodule ExOanda.ResponseTest do
  use ExUnit.Case, async: true
  alias ExOanda.Response

  describe "changeset/2" do
    test "valid changeset with all required fields" do
      params = %{
        data: %{"account" => %{"id" => "test-account"}},
        request_id: "request-123",
        status: :success
      }

      changeset = Response.changeset(%Response{}, params)

      assert changeset.valid?
      assert changeset.errors == []
    end

    test "valid changeset with error fields" do
      params = %{
        data: nil,
        request_id: "request-123",
        status: :error,
        error_code: "INVALID_REQUEST",
        error_message: "The request is invalid"
      }

      changeset = Response.changeset(%Response{}, params)

      assert changeset.valid?
      assert changeset.errors == []
    end

    test "valid changeset with atom status" do
      params = %{
        data: %{"instruments" => []},
        request_id: "request-456",
        status: "success"
      }

      changeset = Response.changeset(%Response{}, params)

      assert changeset.valid?
      assert changeset.errors == []
    end

    test "invalid changeset with missing required fields" do
      params = %{}

      changeset = Response.changeset(%Response{}, params)

      refute changeset.valid?
      assert length(changeset.errors) == 2
      assert {:request_id, {"can't be blank", [validation: :required]}} in changeset.errors
      assert {:status, {"can't be blank", [validation: :required]}} in changeset.errors
    end

    test "changeset with different data types" do
      # Test with map data
      params = %{
        data: %{"key" => "value"},
        request_id: "request-123",
        status: :success
      }

      changeset = Response.changeset(%Response{}, params)
      assert changeset.valid?, "Map data should be valid"

      # Test with map data (different structure)
      params = %{
        data: %{"items" => [%{"item" => "value"}]},
        request_id: "request-456",
        status: :success
      }

      changeset = Response.changeset(%Response{}, params)
      assert changeset.valid?, "Map data with nested list should be valid"

      # Test with nil data
      params = %{
        data: nil,
        request_id: "request-789",
        status: :error
      }

      changeset = Response.changeset(%Response{}, params)
      assert changeset.valid?, "Nil data with error status should be valid"
    end

    test "changeset with optional error fields" do
      params = %{
        data: nil,
        request_id: "request-123",
        status: :error
      }

      changeset = Response.changeset(%Response{}, params)

      assert changeset.valid?
      assert changeset.data.error_code == nil
      assert changeset.data.error_message == nil
    end
  end
end
