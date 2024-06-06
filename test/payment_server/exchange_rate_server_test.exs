defmodule PaymentServer.ExchangeRateServerTest do
  use ExUnit.Case, async: true

  import PaymentServer.AccountsFixtures, only: [exchange_rate_fixture: 0]
  alias PaymentServer.ExchangeRateServer

  setup do
    {:ok, _pid} = ExchangeRateServer.start_link(:USD, :AUD)
    {:ok, exchange_rate: exchange_rate_fixture()}
  end

  describe "&get_exchange_rate/2" do
    test "when in polling state, get exchange rate", %{exchange_rate: exchange_rate} do
      assert ExchangeRateServer.get_exchange_rate(:USD, :AUD) === {:ok, exchange_rate}
    end
  end

end
