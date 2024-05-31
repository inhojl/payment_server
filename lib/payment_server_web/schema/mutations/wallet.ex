defmodule PaymentServerWeb.Schema.Mutations.Wallet do
  alias PaymentServerWeb.Resolvers
  use Absinthe.Schema.Notation

  object :wallet_mutations do
    field :create_wallet, :wallet do
      arg :currency, non_null(:string)
      arg :user_id, non_null(:id)

      resolve &Resolvers.Wallet.create/2
    end

    field :send_money, :wallet do
      arg :recipient_id, non_null(:id)
      arg :recipient_currency, non_null(:string)
      arg :sender_id, non_null(:id)
      arg :sender_currency, non_null(:id)
      arg :amount, non_null(:string)

      resolve &Resolvers.Wallet.send_money/2
    end

  end

end
