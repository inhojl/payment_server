defmodule PaymentServerWeb.Schema.Queries.UserTest do
  use PaymentServer.DataCase, async: true

  alias PaymentServer.Accounts
  alias PaymentServerWeb.Schema


  @user_query """
  query FindUser($id: IntegerId, $email: String) {
    user(id: $id, email: $email) {
      id,
      email
    }
  }
  """

  @all_users_query """
  query AllUsers($id: IntegerId, $email: String, $before: IntegerId, $after: IntegerId, $first: Int) {
    users(id: $id, email: $email, before: $before, after: $after, first: $first) {
      id,
      email
    }
  }
  """

  setup do
    assert {:ok, user1} = Accounts.create_user(%{
      email: "user1@email.com",
      wallet: %{
        currency: "USD",
        balance: 528.87
      }
    })

    assert {:ok, user2} = Accounts.create_user(%{
      email: "user2@email.com",
      wallet: %{
        currency: "AUS",
        balance: 234.81
      }
    })

    assert {:ok, user3} = Accounts.create_user(%{
      email: "user3@email.com",
      wallet: %{
        currency: "KRW",
        balance: 5100.50
      }
    })

    %{user1: user1, user2: user2, user3: user3}
  end

  describe "@user" do
    test "fetch user by id", %{user1: user1} do
      assert {:ok, %{data: data}} = Absinthe.run(@user_query, Schema,
      variables: %{
        "id" => user1.id
      })

      assert data["user"]["id"] === user1.id
    end

    test "fetch user by email", %{user1: user1} do
      assert {:ok, %{data: data}} = Absinthe.run(@user_query, Schema,
      variables: %{
        "email" => user1.email
      })

      assert data["user"]["email"] === user1.email
    end
  end

  describe "@users" do

    test "fetch users by email", %{user1: user1} do
      assert {:ok, %{data: data}} = Absinthe.run(@all_users_query, Schema,
        variables: %{
          "email" => user1.email
        }
      )

      assert List.first(data["users"])["email"] === user1.email
    end

    test "fetch users by id", %{user1: user1} do
      assert {:ok, %{data: data}} = Absinthe.run(@all_users_query, Schema,
        variables: %{
          "id" => user1.id
        }
      )

      assert List.first(data["users"])["id"] === user1.id
    end

    test "fetch users before id", %{user1: user1, user2: user2} do
      assert {:ok, %{data: data}} = Absinthe.run(@all_users_query, Schema,
      variables: %{
        "before" => to_string(user2.id)
      })

      assert List.first(data["users"])["email"] === user1.email
    end

    test "fetch users after id", %{user2: user2, user3: user3} do
      assert {:ok, %{data: data}} = Absinthe.run(@all_users_query, Schema,
      variables: %{
        "after" => to_string(user2.id)
      })

      assert List.first(data["users"])["email"] === user3.email
    end

    test "fetch first 2 users", %{user1: user1, user2: user2} do
      assert {:ok, %{data: data}} = Absinthe.run(@all_users_query, Schema,
      variables: %{
        "first" => 2
      })

      assert Enum.at(data["users"], 0)["email"] === user1.email
      assert Enum.at(data["users"], 1)["email"] === user2.email
    end
  end


end
