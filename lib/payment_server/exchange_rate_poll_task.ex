defmodule PaymentServer.ExchangeRatePollTask do
  alias PaymentServer.ExchangeRateAgent
  alias PaymentServer.Config
  alias PaymentServer.Behaviours
  use Task, restart: :permanent

  require Logger

  @exchange_rate_topic "exchange_rate"
  @alpha_vantage_module Config.Modules.alpha_vantage()

  def start_link(from_currency, to_currency) do
    Task.start_link(__MODULE__, :run, [from_currency, to_currency])
  end

  def task_name(from_currency, to_currency) do
    :"exchange_rate_task.#{from_currency}_#{to_currency}"
  end

  def child_spec(from_currency, to_currency) do
    %{
      id: task_name(from_currency, to_currency),
      start: {__MODULE__, :start_link, [from_currency, to_currency]}
    }
  end

  def run(from_currency, to_currency) do
    new_exchange_rate =
      case Behaviours.AlphaVantage.get_exchange_rate(
             @alpha_vantage_module,
             from_currency,
             to_currency
           ) do
        {:ok, exchange_rate} ->
          exchange_rate

        {:error, %ErrorMessage{} = error} ->
          Logger.error(error.message, ErrorMessage.to_jsonable_map(error))
          :error
      end

    exchange_rate_graphql = %{
      from_currency: from_currency,
      to_currency: to_currency,
      exchange_rate: new_exchange_rate
    }

    broadcast(
      exchange_rate_graphql,
      topics: [
        @exchange_rate_topic,
        "#{@exchange_rate_topic}:#{to_currency}"
      ]
    )

    ExchangeRateAgent.update_exchange_rate(from_currency, to_currency, new_exchange_rate)

    Process.sleep(:timer.seconds(1))
    run(from_currency, to_currency)
  end

  defp broadcast(currency_exchange_rate, topics: topics) do
    Enum.each(
      topics,
      fn topic ->
        Absinthe.Subscription.publish(PaymentServerWeb.Endpoint, currency_exchange_rate,
          currency_exchange_rate: topic
        )
      end
    )
  end
end
