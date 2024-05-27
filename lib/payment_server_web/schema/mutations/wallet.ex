defmodule PaymentServerWeb.Schema.Mutations.Wallet do
  alias PaymentServerWeb.Resolvers
  use Absinthe.Schema.Notation

  object :wallet_mutations do
    field :create_wallet, :wallet do
      arg :currency, non_null(:string)
      arg :user_id, non_null(:id)

      resolve &Resolvers.Wallet.create/2
    end
  end

end
