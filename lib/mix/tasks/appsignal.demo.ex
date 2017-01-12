defmodule Mix.Tasks.Appsignal.Demo do
  use Mix.Task
  # use Appsignal.Instrumentation.Decorators
  import Appsignal.Instrumentation.Helpers, only: [instrument: 4]

  @shortdoc "Perform and send a demonstration error and performance issue to AppSignal."

  def run(_args) do
    pstart()
  end

  # @decorate transaction
  defp pstart do
    Appsignal.start(nil, nil)
    create_transaction_performance_request()
    create_transaction_error_request()
  end

  defp create_transaction_error_request do
    transaction = Appsignal.Transaction.start(
      Appsignal.Transaction.generate_id,
      :http_request
    )
    |> Appsignal.Transaction.set_action("DemoController#hello")
    |> Appsignal.Transaction.set_meta_data("demo_sample", "true")
    |> Appsignal.Transaction.set_meta_data("path", "/hello")
    |> Appsignal.Transaction.set_meta_data("method", "GET")
    |> Appsignal.Transaction.set_error("AnotherError", "error message", System.stacktrace)

    Appsignal.Transaction.finish(transaction)
    :ok = Appsignal.Transaction.complete(transaction)
  end

  defp create_transaction_performance_request do
    transaction = Appsignal.Transaction.start(
      Appsignal.Transaction.generate_id,
      :http_request
    )
    |> Appsignal.Transaction.set_action("DemoController#hello")
    |> Appsignal.Transaction.set_meta_data("demo_sample", "true")
    |> Appsignal.Transaction.set_meta_data("path", "/hello")
    |> Appsignal.Transaction.set_meta_data("method", "GET")

    instrument(transaction, "phoenix.render", "Rendering something slow", fn() ->
      :timer.sleep(2000)
    end)

    Appsignal.Transaction.finish(transaction)
    :ok = Appsignal.Transaction.complete(transaction)
  end
end
