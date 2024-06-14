defmodule PaymentServerWeb.Schema.Queries.User do
  use Absinthe.Schema.Notation

  alias PaymentServerWeb.Resolvers

  object :user_queries do
    field :user, :user do
      arg :id, :id
      arg :email, :string

      resolve &Resolvers.User.find/2
    end

    field :users, list_of(:user) do
      arg :id, :id
      arg :email, :string
      arg :before, :id
      arg :after, :id
      arg :first, :integer

      resolve &Resolvers.User.all/2
    end
  end
end
