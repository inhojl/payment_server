defmodule PaymentServer.Behaviours.AlphaVantage do
  @callback get_exchange_rate(atom(), atom()) :: {:ok, Decimal.t} | {:error, term()}

  def get_exchange_rate(module, from_currency, to_currency) do
    module.get_exchange_rate(from_currency, to_currency)
  end
end
