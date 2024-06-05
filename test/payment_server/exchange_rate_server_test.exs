defmodule PaymentServer.ExchangeRateServerTest do
  use ExUnit.Case, async: true
  alias PaymentServer.ExchangeRateServer
  import PaymentServer.AccountsFixtures, only: [exchange_rate_fixture: 0]

  setup do
    {:ok, _pid} = ExchangeRateServer.start_link(:USD, :AUD)
    {:ok, exchange_rate: exchange_rate_fixture()}
  end

  describe "&get_exchange_rate/2" do
    test "get exchange rate when server is in poll state", %{exchange_rate: exchange_rate} do
      assert ExchangeRateServer.get_exchange_rate(:USD, :AUD) === {:ok, exchange_rate}
    end
  end

end
