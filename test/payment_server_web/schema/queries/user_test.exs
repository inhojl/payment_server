defmodule PaymentServerWeb.Schema.Queries.UserTest do
  use PaymentServer.DataCase, async: true

  import PaymentServer.AccountsFixtures, only: [users_fixture: 0]
  alias PaymentServerWeb.Schema

  setup do
    users_fixture()
  end

  @user_query """
  query FindUser($id: ID, $email: String) {
    user(id: $id, email: $email) {
      id,
      email
    }
  }
  """

  describe "@user" do
    test "fetch user by id", %{user1: user1} do
      assert {:ok, %{data: data}} =
               Absinthe.run(@user_query, Schema,
                 variables: %{
                   "id" => user1.id
                 }
               )

      assert data["user"]["id"] === to_string(user1.id)
    end

    test "fetch user by email", %{user1: user1} do
      assert {:ok, %{data: data}} =
               Absinthe.run(@user_query, Schema,
                 variables: %{
                   "email" => user1.email
                 }
               )

      assert data["user"]["email"] === user1.email
    end
  end

  @all_users_query """
  query AllUsers($id: ID, $email: String, $before: ID, $after: ID, $first: Int) {
    users(id: $id, email: $email, before: $before, after: $after, first: $first) {
      id,
      email
    }
  }
  """

  describe "@users" do
    test "fetch users by email", %{user1: user1} do
      assert {:ok, %{data: data}} =
               Absinthe.run(@all_users_query, Schema,
                 variables: %{
                   "email" => user1.email
                 }
               )

      assert List.first(data["users"])["email"] === user1.email
    end

    test "fetch users by id", %{user1: user1} do
      assert {:ok, %{data: data}} =
               Absinthe.run(@all_users_query, Schema,
                 variables: %{
                   "id" => user1.id
                 }
               )

      assert List.first(data["users"])["id"] === to_string(user1.id)
    end

    test "fetch users before id", %{user1: user1, user2: user2} do
      assert {:ok, %{data: data}} =
               Absinthe.run(@all_users_query, Schema,
                 variables: %{
                   "before" => to_string(user2.id)
                 }
               )

      assert List.first(data["users"])["email"] === user1.email
    end

    test "fetch users after id", %{user2: user2, user3: user3} do
      assert {:ok, %{data: data}} =
               Absinthe.run(@all_users_query, Schema,
                 variables: %{
                   "after" => to_string(user2.id)
                 }
               )

      assert List.first(data["users"])["email"] === user3.email
    end

    test "fetch first 2 users", %{user1: user1, user2: user2} do
      assert {:ok, %{data: data}} =
               Absinthe.run(@all_users_query, Schema,
                 variables: %{
                   "first" => 2
                 }
               )

      assert Enum.at(data["users"], 0)["email"] === user1.email
      assert Enum.at(data["users"], 1)["email"] === user2.email
    end
  end
end
