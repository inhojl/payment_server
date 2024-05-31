defmodule PaymentServerWeb.Schema.Subscriptions.ExchangeRate do
  use Absinthe.Schema.Notation

  object :exchange_rate_subscriptions do

    field :currency_exchange_rate, :currency_exchange_rate do
      arg :currency, :string

      config fn
        %{currency: currency} -> {:ok, topic: "exchange_rate:#{currency}"}
        _ -> {:ok, topic: "exchange_rate"}
      end
    end
  end

end
