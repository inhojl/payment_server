defmodule PaymentServerWeb.Schema.Queries.WalletTest do
  use PaymentServer.DataCase

  alias PaymentServer.Accounts
  alias PaymentServerWeb.Schema

  @wallet_query """
  query FindWallet($id: ID) {
    wallet(id: $id) {
      id
      currency
      balance
      user_id
    }
  }

  """

  @wallets_query """
  query AllWallets($userId: ID, $currency: String, $first: Int, $before: ID, $after: ID) {
    wallets(userId: $userId, currency: $currency, first: $first, before: $before, after: $after) {
      id
      currency
      balance
      user_id
    }
  }

  """

  setup do
    assert {:ok, user1} = Accounts.create_user(%{
      email: "user1@email.com",
      wallets: [%{
        currency: "USD",
        balance: 1459.94
      }, %{
        currency: "KRW",
        balance: 1123.12
      }]
    })

    assert {:ok, user2} = Accounts.create_user(%{
      email: "user2@email.com",
      wallets: [%{
        currency: "USD",
        balance: 123.94
      }, %{
        currency: "KRW",
        balance: 68.12
      }]
    })

    %{user1: user1, user2: user2}
  end

  describe "@wallet" do
    test "fetch wallet by id", %{user1: %{wallets: [wallet1 | _]}} do
      assert {:ok, %{data: data}} = Absinthe.run(@wallet_query, Schema,
      variables: %{
        "id" => wallet1.id
      })

      assert data["wallet"]["id"] === to_string(wallet1.id)
    end
  end

  describe "@wallets" do
    test "fetch wallets by userId", %{user1: user1} do
      assert {:ok, %{data: data}} = Absinthe.run(@wallets_query, Schema,
      variables: %{
        "userId" => user1.id
      })

      wallet_ids = Enum.map(user1.wallets, &(to_string(&1.id)))

      assert Enum.all?(data["wallets"], &(&1["id"] in wallet_ids))
    end

    test "fetch wallets by userId and currency", %{user1: %{id: id, wallets: [wallet1 | _]}} do
      assert {:ok, %{data: data}} = Absinthe.run(@wallets_query, Schema,
      variables: %{
        "userId" => id,
        "currency" => wallet1.currency
      })

      wallet = Enum.at(data["wallets"], 0)
      assert wallet["id"] === to_string(wallet1.id)
      assert wallet["currency"] === wallet1.currency
    end

    test "fetch first 2 wallets", %{user1: %{wallets: user1_wallets}} do
      assert {:ok, %{data: data}} = Absinthe.run(@wallets_query, Schema,
      variables: %{
        "first" => 2
      })

      wallet_ids = Enum.map(user1_wallets, &(to_string(&1.id)))

      assert Enum.all?(data["wallets"], &(&1["id"] in wallet_ids))
    end

    test "fetch wallet before id", %{user1: %{wallets: user1_wallets}, user2: %{wallets: [%{id: id} | _]}} do
      assert {:ok, %{data: data}} = Absinthe.run(@wallets_query, Schema,
      variables: %{
        "before" => id
      })
      wallet_ids = Enum.map(user1_wallets, &(to_string(&1.id)))

      assert Enum.all?(data["wallets"], &(&1["id"] in wallet_ids))
    end

    test "fetch wallet after id", %{user1: %{wallets: [_, %{id: id}]}, user2: %{wallets: user2_wallets}} do
      assert {:ok, %{data: data}} = Absinthe.run(@wallets_query, Schema,
      variables: %{
        "after" => id
      })

      wallet_ids = Enum.map(user2_wallets, &(to_string(&1.id)))

      assert Enum.all?(data["wallets"], &(&1["id"] in wallet_ids))
    end
  end



end
