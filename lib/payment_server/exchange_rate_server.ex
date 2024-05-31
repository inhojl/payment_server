defmodule PaymentServer.ExchangeRateServer do
  require Logger
  alias PaymentServer.Apis.AlphaVantage
  use GenServer


  def start_link(from_currency, to_currency, opts \\ []) do

    opts = Keyword.put_new(opts, :name, server_name(from_currency, to_currency))
    GenServer.start_link(__MODULE__, %{from_currency: from_currency, to_currency: to_currency, exchange_rate: nil}, opts)
  end

  def child_spec(from_currency, to_currency) do
    %{
      id: server_name(from_currency, to_currency),
      start: {__MODULE__, :start_link, [from_currency, to_currency]}
    }
  end

  def init(state) do
    {:ok, state, {:continue, :init_poll_exchange_rate}}
  end

  def handle_continue(:init_poll_exchange_rate, %{from_currency: from_currency, to_currency: to_currency} = state) do
    new_exchange_rate = poll_exchange_rate(from_currency, to_currency)
    new_state = %{state | exchange_rate: new_exchange_rate}
    broadcast(new_state, topics: ["exchange_rate", "exchange_rate:#{from_currency}"])
    {:noreply,new_state}
  end

  def handle_info(:poll_exchange_rate,  %{from_currency: from_currency, to_currency: to_currency} = state) do
    new_exchange_rate = poll_exchange_rate(from_currency, to_currency)
    new_state = %{state | exchange_rate: new_exchange_rate}
    broadcast(new_state, topics: ["exchange_rate", "exchange_rate:#{from_currency}"])
    {:noreply, new_state}
  end

  defp poll_exchange_rate(from_currency, to_currency) do
    exchange_rate = fetch_exchange_rate(from_currency, to_currency)
    Process.send_after(self(), :poll_exchange_rate, :timer.seconds(1))
    exchange_rate
  end

  defp fetch_exchange_rate(from_currency, to_currency) do
    with {:ok, exchange_rate} <- AlphaVantage.get_exchange_rate(from_currency, to_currency) do
      Decimal.new(exchange_rate)
    else
      {:error, %ErrorMessage{} = error} ->
        Logger.error(error.message, error)
        nil
      {:error, error} ->
        Logger.error(inspect(error))
        nil
    end
  end

  defp broadcast(currency_exchange_rate, topics: topics) do
    Enum.each(topics, &(Absinthe.Subscription.publish(PaymentServerWeb.Endpoint, currency_exchange_rate, currency_exchange_rate: &1)))
  end

  defp server_name(from_currency, to_currency) do
    :"exchange_rate_server.#{from_currency}_#{to_currency}"
  end


end
