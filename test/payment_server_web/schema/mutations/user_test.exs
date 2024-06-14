defmodule PaymentServerWeb.Schema.Mutations.UserTest do
  alias PaymentServerWeb.Schema
  use PaymentServer.DataCase

  @create_user """
  mutation CreateUser($email: String!) {
    createUser(email: $email) {
      id
      email
    }
  }
  """

  describe "@create_user" do
    test "create user with email" do
      assert {:ok, %{data: data}} =
               Absinthe.run(@create_user, Schema,
                 variables: %{
                   "email" => "user1@email.com"
                 }
               )

      refute is_nil(data["createUser"]["id"])
      assert data["createUser"]["email"] === "user1@email.com"
    end
  end
end
