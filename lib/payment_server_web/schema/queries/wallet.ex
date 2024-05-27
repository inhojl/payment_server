defmodule PaymentServerWeb.Schema.Queries.Wallet do
  use Absinthe.Schema.Notation
  alias PaymentServerWeb.Resolvers

  object :wallet_queries do
    field :wallet, :wallet do
      arg :id, :id
      arg :user_id, :id
      arg :currency, :string

      resolve &Resolvers.Wallet.find/2
    end

    field :wallets, list_of(:wallet) do
      arg :user_id, :id
      arg :currency, :string
      arg :first, :integer
      arg :before, :id
      arg :after, :id

      resolve &Resolvers.Wallet.all/2
    end
  end

end
