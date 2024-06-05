defmodule PaymentServerWeb.Schema.Mutations.Wallet do
  alias PaymentServerWeb.Middlewares.CurrencyValidator
  alias PaymentServerWeb.Resolvers
  use Absinthe.Schema.Notation

  object :wallet_mutations do
    field :create_wallet, :wallet do
      arg :currency, non_null(:string)
      arg :user_id, non_null(:integer_id)

      middleware CurrencyValidator
      resolve &Resolvers.Wallet.create/2
    end

    field :send_money, :wallet do
      arg :recipient_id, non_null(:integer_id)
      arg :recipient_currency, non_null(:string)
      arg :sender_id, non_null(:integer_id)
      arg :sender_currency, non_null(:string)
      arg :amount, non_null(:decimal)

      middleware CurrencyValidator
      resolve &Resolvers.Wallet.send_money/2
    end

  end

end
