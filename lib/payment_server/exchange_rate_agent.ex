defmodule PaymentServer.ExchangeRateAgent do
  use Agent, restart: :permanent

  def agent_name(from_currency, to_currency) do
    :"exchange_rate_agent.#{from_currency}_#{to_currency}"
  end

  def child_spec(from_currency, to_currency) do
    %{
      id: agent_name(from_currency, to_currency),
      start: {__MODULE__, :start_link, [from_currency, to_currency]}
    }
  end

  def start_link(from_currency, to_currency) do
    init_state = %{
      from_currency: from_currency,
      to_currency: to_currency,
      exchange_rate: :error
    }

    Agent.start_link(fn -> init_state end, name: agent_name(from_currency, to_currency))
  end

  def get_exchange_rate(from_currency, to_currency) do
    Agent.get(agent_name(from_currency, to_currency), fn
      %{exchange_rate: :error} ->
        {:error, ErrorMessage.internal_server_error("Failed to retrieve exchange rate")}

      %{exchange_rate: exchange_rate} ->
        {:ok, exchange_rate}
    end)
  end

  def update_exchange_rate(from_currency, to_currency, exchange_rate) do
    Agent.update(agent_name(from_currency, to_currency), fn state ->
      %{state | exchange_rate: exchange_rate}
    end)
  end
end
