defmodule Mix.Tasks.Appsignal.Demo do
  use Mix.Task
  # use Appsignal.Instrumentation.Decorators
  import Appsignal.Instrumentation.Helpers, only: [instrument: 4]

  @shortdoc "Perform and send a demonstration error and performance issue to AppSignal."

  def run(_args) do
    IO.puts "Hello world"
    pstart()
  end

  # @decorate transaction
  defp pstart do
    Appsignal.start(nil, nil)
    IO.inspect Appsignal.started?()
    # create_transaction_error_request()
    create_transaction_performance_request()
  end

  # @decorate transaction_event
  defp create_transaction_error_request do
    transaction = Appsignal.Transaction.start(
      Appsignal.Transaction.generate_id,
      :http_request
    )
    |> Appsignal.Transaction.set_action("DemoController#hello")
    |> Appsignal.Transaction.set_meta_data("demo_sample", "true")
    |> Appsignal.Transaction.set_meta_data("path", "/hello")
    |> Appsignal.Transaction.set_meta_data("method", "GET")

    try do
      raise TestError
    rescue
      error in TestError -> transaction.set_error(error)
    end

    Appsignal.Transaction.finish(transaction)
    :ok = Appsignal.Transaction.complete(transaction)
  end

  # @decorate transaction_event
  defp create_transaction_performance_request do
    transaction = Appsignal.Transaction.start(
      Appsignal.Transaction.generate_id,
      :http_request
    )
    |> Appsignal.Transaction.set_action("DemoController#hello")
    |> Appsignal.Transaction.set_meta_data("demo_sample", "true")
    |> Appsignal.Transaction.set_meta_data("path", "/hello")
    |> Appsignal.Transaction.set_meta_data("method", "GET")

    instrument transaction, "phoenix.render", "Rendering something slow", fn() ->
      :timer.sleep(2000)
    end

    Appsignal.Transaction.finish(transaction)
    IO.inspect Appsignal.Transaction.complete(transaction)
  end

  defmodule TestError do
    defexception message: "Hello world! This is an error used for demonstration purposes."
  end
end
