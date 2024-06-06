defmodule PaymentServerWeb.Schema.Subscriptions.ExchangeRateTest do
  use PaymentServerWeb.SubscriptionCase

  import PaymentServer.AccountsFixtures, only: [exchange_rate_fixture: 0]
  alias PaymentServer.ExchangeRateServer

  setup do
    from_currency = "USD"
    to_currency = "KRW"
    {:ok, _pid} = ExchangeRateServer.start_link(from_currency, to_currency)
    %{from_currency: from_currency, to_currency: to_currency, exchange_rate: exchange_rate_fixture()}
  end


  @exchange_rate_subscription """
  subscription ExchangeRate($toCurrency: String) {
    currencyExchangeRate(toCurrency: $toCurrency) {
      fromCurrency
      toCurrency
      exchangeRate
    }
  }
  """

  describe "@@exchange_rate_subscription" do
    test "polling all exchange rates", %{
      socket: socket,
      from_currency: from_currency,
      to_currency: to_currency,
      exchange_rate: exchange_rate
    } do

      ref = push_doc socket, @exchange_rate_subscription
      assert_reply ref, :ok, %{subscriptionId: subscription_id}

      exchange_rate = to_string(exchange_rate)
      assert_push "subscription:data", data, 3_000
      assert %{
        subscriptionId: ^subscription_id,
        result: %{
          data: %{
            "currencyExchangeRate" => %{
              "exchangeRate" => ^exchange_rate,
              "fromCurrency" => ^from_currency,
              "toCurrency" => ^to_currency
            }
          }
        }} = data
    end

    test "polling specific exchange rate", %{
      socket: socket,
      from_currency: from_currency,
      to_currency: to_currency,
      exchange_rate: exchange_rate
    } do

      ref = push_doc socket, @exchange_rate_subscription, variables: %{"toCurrency" => to_currency}
      assert_reply ref, :ok, %{subscriptionId: subscription_id}

      exchange_rate = to_string(exchange_rate)
      assert_push "subscription:data", data, 3_000
      assert %{
        subscriptionId: ^subscription_id,
        result: %{
          data: %{
            "currencyExchangeRate" => %{
              "exchangeRate" => ^exchange_rate,
              "fromCurrency" => ^from_currency,
              "toCurrency" => ^to_currency
            }
          }
        }} = data
    end
  end

end
