defmodule PaymentServer.Support.AlphaVantage do
  @behaviour PaymentServer.Behaviours.AlphaVantage
  import PaymentServer.AccountsFixtures, only: [exchange_rate_fixture: 0]

  @impl PaymentServer.Behaviours.AlphaVantage
  def get_exchange_rate(_from_currency, _to_currency) do
    {:ok, exchange_rate_fixture()}
  end
end
