defmodule PaymentServerWeb.Types.Wallet do
  use Absinthe.Schema.Notation

  object :wallet do
    field :id, :id
    field :user_id, :id
    field :currency, :string
    field :balance, :string
  end

end
