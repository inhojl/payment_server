defmodule PaymentServerWeb.Schema.Subscriptions.Transaction do
  use Absinthe.Schema.Notation

  object :transaction_subscriptions do
    field :transaction, :transaction do
      arg :user_id, non_null(:id)

      config fn
        %{user_id: user_id}, _ -> {:ok, topic: "transaction:#{user_id}"}
      end
    end
  end
end
