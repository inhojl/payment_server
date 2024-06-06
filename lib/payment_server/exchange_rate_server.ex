defmodule PaymentServer.ExchangeRateServer do
  use GenServer

  require Logger
  alias PaymentServer.Behaviours
  alias PaymentServer.Config

  @exchange_rate_topic "exchange_rate"
  @alpha_vantage_module Config.Modules.alpha_vantage()

  def server_name(from_currency, to_currency) do
    :"exchange_rate_server.#{from_currency}_#{to_currency}"
  end

  def child_spec(from_currency, to_currency) do
    %{
      id: server_name(from_currency, to_currency),
      start: {__MODULE__, :start_link, [from_currency, to_currency]}
    }
  end

  def start_link(from_currency, to_currency, opts \\ []) do
    opts = Keyword.put_new(opts, :name, server_name(from_currency, to_currency))
    init_state = %{from_currency: from_currency, to_currency: to_currency, exchange_rate: :error}
    GenServer.start_link(__MODULE__, init_state, opts)
  end

  def init(state) do
    {:ok, state, {:continue, :init_poll_exchange_rate}}
  end

  def handle_continue(:init_poll_exchange_rate, %{from_currency: from_currency, to_currency: to_currency} = state) do
    new_exchange_rate = poll_exchange_rate(from_currency, to_currency)
    new_state = %{state | exchange_rate: new_exchange_rate}
    broadcast(new_state, topics: [@exchange_rate_topic, "#{@exchange_rate_topic}:#{to_currency}"])
    {:noreply, new_state}
  end

  def handle_info(:poll_exchange_rate,  %{from_currency: from_currency, to_currency: to_currency} = state) do
    new_exchange_rate = poll_exchange_rate(from_currency, to_currency)
    new_state = %{state | exchange_rate: new_exchange_rate}
    broadcast(new_state, topics: [@exchange_rate_topic, "#{@exchange_rate_topic}:#{to_currency}"])
    {:noreply, new_state}
  end

  defp poll_exchange_rate(from_currency, to_currency) do
    new_exchange_rate = case Behaviours.AlphaVantage.get_exchange_rate(@alpha_vantage_module, from_currency, to_currency) do
      {:ok, exchange_rate} -> exchange_rate
      {:error, %ErrorMessage{} = error} ->
        Logger.error(error.message, ErrorMessage.to_jsonable_map(error))
        :error
    end
    Process.send_after(self(), :poll_exchange_rate, :timer.seconds(1))
    new_exchange_rate
  end

  defp broadcast(currency_exchange_rate, topics: topics) do
    Enum.each(topics, &(Absinthe.Subscription.publish(PaymentServerWeb.Endpoint, currency_exchange_rate, currency_exchange_rate: &1)))
  end

  def get_exchange_rate(from_currency, to_currency) do
    GenServer.call(server_name(from_currency, to_currency), :get_exchange_rate)
  end

  def handle_call(:get_exchange_rate, _, %{exchange_rate: :error} = state) do
    {:reply, {:error, ErrorMessage.internal_server_error("Failed to retrieve exchange rate")}, {:internal, state}}
  end

  def handle_call(:get_exchange_rate, _, %{exchange_rate: exchange_rate} = state) do
    {:reply, {:ok, exchange_rate}, state}
  end

end
