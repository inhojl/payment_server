defmodule PaymentServerWeb.Schema.Queries.Wallet do
  use Absinthe.Schema.Notation

  alias PaymentServerWeb.Middlewares.CurrencyValidator
  alias PaymentServerWeb.Resolvers

  object :wallet_queries do
    field :wallet, :wallet do
      arg :id, :id
      arg :user_id, :id
      arg :currency, :string

      middleware CurrencyValidator
      resolve &Resolvers.Wallet.find/2
    end

    field :wallets, list_of(:wallet) do
      arg :user_id, :id
      arg :currency, :string
      arg :first, :integer
      arg :before, :id
      arg :after, :id

      middleware CurrencyValidator
      resolve &Resolvers.Wallet.all/2
    end

    field :total_worth, :string do
      arg :user_id, non_null(:id)
      arg :currency, non_null(:string)

      middleware CurrencyValidator
      resolve &Resolvers.Wallet.calculate_total_worth/2
    end
  end
end
