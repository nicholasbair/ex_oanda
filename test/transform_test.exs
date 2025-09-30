defmodule ExOanda.TransformTest do
  use ExUnit.Case, async: true
  import ExUnit.CaptureLog
  alias ExOanda.ClientPrice
  alias ExOanda.Response
  alias ExOanda.Response.PricingHeartbeat
  alias ExOanda.Response.TransactionEvent
  alias ExOanda.Test.Support.MockModel
  alias ExOanda.Transform

  describe "transform/2" do
    test "transforms response with valid data" do
      response = %{
        body: %{"accountId" => "123", "accountName" => "Test Account"},
        status: 200,
        headers: %{"requestid" => ["req-123"]}
      }

      result = Transform.transform(response, nil)

      assert %Response{} = result
      assert result.status == :ok
      assert result.request_id == "req-123"
      assert result.error_code == nil
      assert result.error_message == nil
      assert result.data == %{"accountId" => "123", "accountName" => "Test Account"}
    end

    test "transforms response with error data" do
      response = %{
        body: %{
          "errorCode" => "INVALID_REQUEST",
          "errorMessage" => "Invalid request parameters"
        },
        status: 400,
        headers: %{"requestid" => ["req-456"]}
      }

      result = Transform.transform(response, nil)

      assert %Response{} = result
      assert result.status == :bad_request
      assert result.request_id == "req-456"
      assert result.error_code == "INVALID_REQUEST"
      assert result.error_message == "Invalid request parameters"
    end

    test "handles response with empty headers" do
      response = %{
        body: %{"data" => "test"},
        status: 201,
        headers: %{}
      }

      result = Transform.transform(response, nil)

      assert %Response{} = result
      assert result.status == :created
      assert result.request_id == nil
    end

    test "handles response with missing headers" do
      response = %{
        body: %{"data" => "test"},
        status: 204
      }

      result = Transform.transform(response, nil)

      assert %Response{} = result
      assert result.status == :no_content
      assert result.request_id == nil
    end

    test "handles response with unknown status code" do
      response = %{
        body: %{"data" => "test"},
        status: 999,
        headers: %{"requestid" => ["req-999"]}
      }

      result = Transform.transform(response, nil)

      assert %Response{} = result
      assert result.status == :unknown
      assert result.request_id == "req-999"
    end
  end

  describe "transform_stream/2" do
    test "transforms transaction stream data" do
      json_data = %{
        "type" => "ORDER_FILL",
        "id" => "123",
        "time" => "2023-01-01T00:00:00.000000000Z",
        "user_id" => 1,
        "account_id" => "456",
        "batch_id" => "batch-123",
        "request_id" => "req-123",
        "order_id" => "order-123",
        "instrument" => "EUR_USD",
        "units" => 1000,
        "full_vwap" => 1.1000,
        "reason" => "MARKET_ORDER",
        "pl" => 0.0,
        "quote_pl" => 0.0,
        "financing" => 0.0,
        "base_financing" => 0.0,
        "account_balance" => 10_000.0,
        "half_spread_cost" => 0.0
      }

      result = Transform.transform_stream(Jason.encode!(json_data), :transactions)

      assert %TransactionEvent{} = result
      assert result.event.__struct__ == ExOanda.OrderFillTransaction
    end

    test "transforms pricing heartbeat stream data" do
      json_data = %{
        "type" => "HEARTBEAT",
        "time" => "2023-01-01T00:00:00.000000000Z"
      }

      result = Transform.transform_stream(Jason.encode!(json_data), :pricing)

      assert %PricingHeartbeat{} = result
      assert result.type == :HEARTBEAT
    end

    test "transforms pricing client price stream data" do
      json_data = %{
        "type" => "PRICE",
        "instrument" => "EUR_USD",
        "time" => "2023-01-01T00:00:00.000000000Z",
        "tradeable" => true,
        "closeoutBid" => 1.1000,
        "closeoutAsk" => 1.1001,
        "bids" => [],
        "asks" => []
      }

      result = Transform.transform_stream(Jason.encode!(json_data), :pricing)

      assert %ClientPrice{} = result
      assert result.type == :PRICE
      assert result.instrument == "EUR_USD"
    end

    test "transforms pricing stream data without type field" do
      json_data = %{
        "instrument" => "EUR_USD",
        "time" => "2023-01-01T00:00:00.000000000Z",
        "tradeable" => true,
        "closeoutBid" => 1.1000,
        "closeoutAsk" => 1.1001,
        "bids" => [],
        "asks" => []
      }

      result = Transform.transform_stream(Jason.encode!(json_data), :pricing)

      assert %ClientPrice{} = result
      assert result.instrument == "EUR_USD"
    end
  end

  describe "preprocess_data/2" do
    test "returns data unchanged when model is nil" do
      data = %{"test" => "value"}
      result = Transform.preprocess_data(nil, data)
      assert result == data
    end

    test "processes map data with valid model" do
      data = %{"accountId" => "123", "accountName" => "Test Account"}
      result = Transform.preprocess_data(nil, data)

      assert result == %{"accountId" => "123", "accountName" => "Test Account"}
    end

    test "processes list data with model" do
      data = [
        %{"accountId" => "123", "accountName" => "Account 1"},
        %{"accountId" => "456", "accountName" => "Account 2"}
      ]

      result = Transform.preprocess_data(nil, data)

      assert is_list(result)
      assert length(result) == 2
      assert result == data
    end

    test "returns data unchanged for non-map, non-list data" do
      data = "string data"
      result = Transform.preprocess_data(nil, data)
      assert result == data

      data = 123
      result = Transform.preprocess_data(nil, data)
      assert result == data

      data = :atom
      result = Transform.preprocess_data(nil, data)
      assert result == data
    end

    test "returns data unchanged for non-map, non-list data with model" do
      data = "string data"
      result = Transform.preprocess_data(MockModel, data)
      assert result == data

      data = 123
      result = Transform.preprocess_data(MockModel, data)
      assert result == data

      data = :atom
      result = Transform.preprocess_data(MockModel, data)
      assert result == data
    end

    test "handles validation errors and logs warnings" do
      data = %{"optional_field" => "value"}

      log_output = capture_log(fn ->
        result = Transform.preprocess_data(MockModel, data)
        assert %MockModel{} = result
        assert result.required_field == nil
      end)

      assert log_output =~ "Validation error while transforming ExOanda.Test.Support.MockModel"
    end

    test "does not log warnings for valid changesets" do
      data = %{"required_field" => "test"}

      log_output = capture_log(fn ->
        result = Transform.preprocess_data(MockModel, data)
        assert %MockModel{} = result
        assert result.required_field == "test"
      end)

      assert log_output == ""
    end

    test "covers log_validations with valid changeset" do
      data = %{"required_field" => "test"}
      result = Transform.preprocess_data(MockModel, data)
      assert %MockModel{} = result
      assert result.required_field == "test"
    end

    test "covers CodeGenerator.format_module_name call in log_validations" do
      data = %{"invalid_field" => "value"}

      log_output = capture_log(fn ->
        result = Transform.preprocess_data(MockModel, data)
        assert %MockModel{} = result
      end)

      assert log_output =~ "ExOanda.Test.Support.MockModel"
    end

    test "covers traverse_errors function call in log_validations" do
      data = %{"invalid_field" => "value"}

      log_output = capture_log(fn ->
        result = Transform.preprocess_data(MockModel, data)
        assert %MockModel{} = result
      end)

      assert log_output =~ "required_field can't be blank"
      assert log_output =~ "validation: :required"
    end
  end

  describe "edge cases and error handling" do
    test "handles empty response body" do
      response = %{
        body: %{},
        status: 200,
        headers: %{"requestid" => ["req-empty"]}
      }

      result = Transform.transform(response, nil)

      assert %Response{} = result
      assert result.data == %{}
      assert result.error_code == nil
      assert result.error_message == nil
    end

    test "handles empty list data" do
      data = []
      result = Transform.preprocess_data(nil, data)
      assert result == []
    end

    test "handles nested list processing" do
      data = [
        [%{"nested" => "data1"}],
        [%{"nested" => "data2"}]
      ]

      result = Transform.preprocess_data(nil, data)

      assert is_list(result)
      assert length(result) == 2
      assert Enum.all?(result, &is_list/1)
    end

    test "handles invalid JSON in transform_stream" do
      assert_raise ExOanda.DecodeError, fn ->
        Transform.transform_stream("invalid json", :pricing)
      end
    end

    test "covers preprocess_data with model and map data" do
      data = %{"required_field" => "test_value"}
      result = Transform.preprocess_data(MockModel, data)

      assert %MockModel{} = result
      assert result.required_field == "test_value"
    end

    test "covers preprocess_data with model and list data" do
      data = [%{"required_field" => "test1"}, %{"required_field" => "test2"}]
      result = Transform.preprocess_data(MockModel, data)

      assert is_list(result)
      assert length(result) == 2
      assert Enum.all?(result, &(%MockModel{} = &1))
    end
  end
end
