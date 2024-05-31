defmodule PaymentServerWeb.Schema.Mutations.User do
  alias PaymentServerWeb.Resolvers
  use Absinthe.Schema.Notation

  object :user_mutations do
    field :create_user, :user do
      arg :email, non_null(:string)

      resolve &Resolvers.User.create/2
    end
  end


end
