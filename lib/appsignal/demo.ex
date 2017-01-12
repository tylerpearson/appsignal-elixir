defmodule Appsignal.Demo do
  alias Appsignal.ErrorHandler
  import Appsignal.Instrumentation.Helpers, only: [instrument: 4]

  def transmit do
    Appsignal.start(nil, nil)
    create_transaction_performance_request()
    create_transaction_error_request()
    Appsignal.stop(nil)
  end

  @doc false
  def create_transaction_error_request do
    transaction = create_demo_transaction()
    Appsignal.Transaction.set_error(
      transaction,
      "TestError",
      "Hello world! This is an error used for demonstration purposes.",
      ErrorHandler.format_stack(System.stacktrace)
    )

    finish_demo_transaction(transaction)
  end

  @doc false
  def create_transaction_performance_request do
    transaction = create_demo_transaction()

    instrument(transaction, "template.render", "Rendering something slow", fn() ->
      :timer.sleep(10)
      instrument(transaction, "ecto.query", "Slow query", fn() ->
        :timer.sleep(30)
      end)
      instrument(transaction, "ecto.query", "Slow query", fn() ->
        :timer.sleep(50)
      end)
      instrument(transaction, "template.render", "Rendering something slow", fn() ->
        :timer.sleep(10)
      end)
    end)

    finish_demo_transaction(transaction)
  end

  @doc false
  defp create_demo_transaction do
    Appsignal.Transaction.start(
      Appsignal.Transaction.generate_id,
      :http_request
    )
    |> Appsignal.Transaction.set_action("DemoController#hello")
    |> Appsignal.Transaction.set_meta_data("demo_sample", "true")
    |> Appsignal.Transaction.set_meta_data("path", "/hello")
    |> Appsignal.Transaction.set_meta_data("method", "GET")
  end

  @doc false
  defp finish_demo_transaction(transaction) do
    Appsignal.Transaction.finish(transaction)
    :ok = Appsignal.Transaction.complete(transaction)
  end
end
