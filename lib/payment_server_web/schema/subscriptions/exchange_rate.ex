defmodule PaymentServerWeb.Schema.Subscriptions.ExchangeRate do
  use Absinthe.Schema.Notation

  object :exchange_rate_subscriptions do
    field :currency_exchange_rate, :currency_exchange_rate do
      arg :to_currency, :string

      config fn
        %{to_currency: to_currency}, _ ->
          {:ok, topic: "exchange_rate:#{to_currency}"}

        _, _ ->
          {:ok, topic: "exchange_rate"}
      end
    end
  end
end
