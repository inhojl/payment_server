defmodule PaymentServerWeb.Types.Transaction do
  use Absinthe.Schema.Notation

  object :transaction do
    field :wallet_id, :id
    field :user_id, :id
    field :currency, :string
    field :transaction_amount, :decimal
    field :transaction_type, :string
  end
end
