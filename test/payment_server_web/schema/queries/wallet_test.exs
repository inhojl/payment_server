defmodule PaymentServerWeb.Schema.Queries.WalletTest do
  use PaymentServer.DataCase, async: true

  import PaymentServer.AccountsFixtures, only: [exchange_rate_fixture: 0, users_fixture: 0]
  alias PaymentServer.Accounts
  alias PaymentServerWeb.Schema
  alias PaymentServer.ExchangeRateServer

  setup do
    assert {:ok, _pid} = ExchangeRateServer.start_link(:KRW, :USD)
    assert {:ok, _pid} = ExchangeRateServer.start_link(:USD, :USD)

    config = users_fixture()
    Map.put_new(config, :exchange_rate, exchange_rate_fixture())
  end

  @wallet_query """
  query FindWallet($id: ID, $userId: ID, $currency: String) {
    wallet(id: $id, userId: $userId, currency: $currency) {
      id
      currency
      balance
      userId
    }
  }

  """

  describe "@wallet" do
    test "fetch wallet by id", %{user1: %{wallets: [wallet1 | _]}} do
      assert {:ok, %{data: data}} =
               Absinthe.run(@wallet_query, Schema,
                 variables: %{
                   "id" => wallet1.id
                 }
               )

      assert data["wallet"]["id"] === to_string(wallet1.id)
    end

    test "fetch wallet by user id and currency", %{user1: %{wallets: [wallet1 | _]}} do
      assert {:ok, %{data: data}} =
               Absinthe.run(@wallet_query, Schema,
                 variables: %{
                   "userId" => wallet1.user_id,
                   "currency" => Atom.to_string(wallet1.currency)
                 }
               )

      assert data["wallet"]["id"] === to_string(wallet1.id)
    end
  end

  @wallets_query """
  query AllWallets($userId: ID, $currency: String, $first: Int, $before: ID, $after: ID) {
    wallets(userId: $userId, currency: $currency, first: $first, before: $before, after: $after) {
      id
      currency
      balance
      userId
    }
  }

  """

  describe "@wallets" do
    test "fetch wallets by userId", %{user1: user1} do
      assert {:ok, %{data: data}} =
               Absinthe.run(@wallets_query, Schema,
                 variables: %{
                   "userId" => user1.id
                 }
               )

      wallet_ids = Enum.map(user1.wallets, &to_string(&1.id))

      assert Enum.all?(data["wallets"], &(&1["id"] in wallet_ids))
    end

    test "fetch wallets by userId and currency", %{user1: %{id: id, wallets: [wallet1 | _]}} do
      assert {:ok, %{data: data}} =
               Absinthe.run(@wallets_query, Schema,
                 variables: %{
                   "userId" => id,
                   "currency" => Atom.to_string(wallet1.currency)
                 }
               )

      wallet = Enum.at(data["wallets"], 0)
      assert wallet["id"] === to_string(wallet1.id)
      assert wallet["currency"] === Atom.to_string(wallet1.currency)
    end

    test "fetch first 2 wallets", %{user1: %{wallets: user1_wallets}} do
      assert {:ok, %{data: data}} =
               Absinthe.run(@wallets_query, Schema,
                 variables: %{
                   "first" => 2
                 }
               )

      wallet_ids = Enum.map(user1_wallets, &to_string(&1.id))

      assert Enum.all?(data["wallets"], &(&1["id"] in wallet_ids))
    end

    test "fetch wallet before id", %{
      user1: %{wallets: user1_wallets},
      user2: %{wallets: [%{id: id} | _]}
    } do
      assert {:ok, %{data: data}} =
               Absinthe.run(@wallets_query, Schema,
                 variables: %{
                   "before" => id
                 }
               )

      wallet_ids = Enum.map(user1_wallets, &to_string(&1.id))

      assert Enum.all?(data["wallets"], &(&1["id"] in wallet_ids))
    end

    test "fetch wallet after id", %{user2: %{wallets: [_, %{id: id}]}, user3: user3} do
      assert {:ok, %{data: data}} =
               Absinthe.run(@wallets_query, Schema,
                 variables: %{
                   "after" => id
                 }
               )

      wallet_ids = Enum.map(user3.wallets, &to_string(&1.id))

      assert Enum.all?(data["wallets"], &(&1["id"] in wallet_ids))
    end
  end

  @total_worth_query """
  query TotalWorth($userId: ID!, $currency: String!) {
    totalWorth(userId: $userId, currency: $currency)
  }
  """

  describe "@total_worth_query" do
    test "calculate expected total worth", %{user1: user1} do
      assert {:ok, %{data: data}} =
               Absinthe.run(@total_worth_query, Schema,
                 variables: %{
                   "userId" => user1.id,
                   "currency" => "USD"
                 }
               )

      expected_total_worth =
        user1.id
        |> Accounts.calculate_total_worth(:USD)
        |> then(fn {:ok, total_worth} -> total_worth end)
        |> Decimal.to_string()

      assert data["totalWorth"] === expected_total_worth
    end
  end
end
