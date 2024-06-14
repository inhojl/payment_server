defmodule PaymentServerWeb.Types.ExchangeRate do
  use Absinthe.Schema.Notation

  object :currency_exchange_rate do
    field :from_currency, :string
    field :to_currency, :string
    field :exchange_rate, :decimal
  end
end
