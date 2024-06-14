defmodule PaymentServer.ExchangeRateAgentTest do
  use ExUnit.Case, async: true

  import PaymentServer.AccountsFixtures, only: [exchange_rate_fixture: 0]
  alias PaymentServer.ExchangeRateAgent
  alias PaymentServer.ExchangeRatePollTask

  setup do
    {:ok, _pid} = ExchangeRateAgent.start_link(:USD, :AUD)
    {:ok, _pid} = ExchangeRatePollTask.start_link(:USD, :AUD)
    {:ok, exchange_rate: exchange_rate_fixture()}
  end

  describe "&get_exchange_rate/2" do
    test "when in polling state, get exchange rate", %{exchange_rate: exchange_rate} do
      Process.sleep(200)
      assert ExchangeRateAgent.get_exchange_rate(:USD, :AUD) === {:ok, exchange_rate}
    end
  end
end
