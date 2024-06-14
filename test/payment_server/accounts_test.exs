defmodule PaymentServer.AccountsTest do
  alias PaymentServer.MoneyTransfer
  use PaymentServer.DataCase, async: true

  import PaymentServer.AccountsFixtures, only: [exchange_rate_fixture: 0, users_fixture: 0]
  alias PaymentServer.Accounts
  alias PaymentServer.ExchangeRateAgent
  alias PaymentServer.ExchangeRatePollTask

  setup do
    {:ok, _pid} = ExchangeRateAgent.start_link(:USD, :AUD)
    {:ok, _pid} = ExchangeRateAgent.start_link(:USD, :KRW)
    {:ok, _pid} = ExchangeRateAgent.start_link(:KRW, :AUD)

    {:ok, _pid} = ExchangeRatePollTask.start_link(:USD, :AUD)
    {:ok, _pid} = ExchangeRatePollTask.start_link(:USD, :KRW)
    {:ok, _pid} = ExchangeRatePollTask.start_link(:KRW, :AUD)

    config = users_fixture()
    Map.put_new(config, :exchange_rate, exchange_rate_fixture())
  end

  describe "&list_users/1" do
    test "fetches all users from the db", %{user1: user1, user2: user2, user3: user3} do
      assert {:ok, [fetched_user1, fetched_user2, fetched_user3]} = Accounts.list_users(%{})
      assert fetched_user1.email === user1.email
      assert fetched_user2.email === user2.email
      assert fetched_user3.email === user3.email
    end
  end

  describe "&find_user/1" do
    test "fetch user by id", %{user1: user1} do
      assert {:ok, user} = Accounts.find_user(%{id: user1.id})
      assert user.email === user1.email
    end

    test "fetch user by email", %{user2: user2} do
      assert {:ok, user} = Accounts.find_user(%{email: user2.email})
      assert user.id === user2.id
    end
  end

  describe "&list_wallets/1" do
    test "fetches all wallets from the db", %{user1: user1, user2: user2} do
      assert {:ok, wallets} = Accounts.list_wallets(%{})

      assert Enum.all?(user1.wallets, &(&1 in wallets))
      assert Enum.all?(user2.wallets, &(&1 in wallets))
    end
  end

  describe "&find_wallet/1" do
    test "fetch wallet by id", %{user1: %{wallets: [wallet1 | _]} = user1} do
      assert {:ok, wallet} = Accounts.find_wallet(%{id: wallet1.id})
      assert wallet.id === wallet1.id
      assert wallet.user_id === user1.id
    end
  end

  describe "&convert_wallet_total/3" do
    test "conversion to same currency should return same balance" do
      input_balance = Decimal.new("1000")
      assert {:ok, balance} = Accounts.convert_wallet_total(:USD, :USD, input_balance)
      assert balance === input_balance
    end

    test "conversion of wallet total to specified currency", %{exchange_rate: exchange_rate} do
      input_balance = Decimal.new("1000")
      assert {:ok, balance} = Accounts.convert_wallet_total(:USD, :AUD, input_balance)
      expected_balance = Decimal.mult(input_balance, exchange_rate)
      assert balance === expected_balance
    end
  end

  describe "&calculate_total_worth/2" do
    test "reduce over wallets and return total worth", %{user1: user1} do
      assert {:ok, total_worth} = Accounts.calculate_total_worth(user1.id, :AUD)

      expected_total_worth =
        Enum.reduce(user1.wallets, Decimal.new("0"), fn wallet, total ->
          wallet.currency
          |> Accounts.convert_wallet_total(:AUD, wallet.balance)
          |> then(fn {:ok, wallet_total} -> wallet_total end)
          |> Decimal.add(total)
        end)

      assert total_worth === expected_total_worth
    end
  end

  describe "&send_money/3" do
    test "send money from and to same currency", %{user1: user1, user2: user2} do
      sender_wallet = Enum.at(user1.wallets, 0)
      recipient_wallet = Enum.at(user2.wallets, 0)
      assert sender_wallet.currency === recipient_wallet.currency

      transaction_amount = Decimal.new("100")

      {:ok, updated_sender_wallet} =
        MoneyTransfer.send_money(sender_wallet, recipient_wallet, transaction_amount)

      {:ok, updated_recipient_wallet} =
        Accounts.find_wallet(%{
          user_id: user2.id,
          currency: recipient_wallet.currency
        })

      assert updated_sender_wallet.balance ===
               Decimal.sub(sender_wallet.balance, transaction_amount)

      assert updated_recipient_wallet.balance ===
               Decimal.add(recipient_wallet.balance, transaction_amount)
    end

    test "send money between different currencies", %{
      user1: user1,
      user2: user2,
      exchange_rate: exchange_rate
    } do
      sender_wallet = Enum.at(user1.wallets, 0)
      recipient_wallet = Enum.at(user2.wallets, 1)
      assert sender_wallet.currency !== recipient_wallet.currency

      transaction_amount = Decimal.new("100")

      {:ok, updated_sender_wallet} =
        MoneyTransfer.send_money(sender_wallet, recipient_wallet, transaction_amount)

      {:ok, updated_recipient_wallet} =
        Accounts.find_wallet(%{
          user_id: user2.id,
          currency: recipient_wallet.currency
        })

      recipient_transaction_amount = Decimal.mult(transaction_amount, exchange_rate)

      assert updated_sender_wallet.balance ===
               Decimal.sub(sender_wallet.balance, transaction_amount)

      assert updated_recipient_wallet.balance ===
               Decimal.add(recipient_wallet.balance, recipient_transaction_amount)
    end
  end
end
