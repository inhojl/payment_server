defmodule PaymentServerWeb.Schema.Mutations.WalletTest do
  use PaymentServer.DataCase

  import PaymentServer.AccountsFixtures, only: [users_fixture: 0, exchange_rate_fixture: 0]
  alias PaymentServerWeb.Schema

  setup do
    config = users_fixture()
    Map.put_new(config, :exchange_rate, exchange_rate_fixture())
  end

  @create_wallet """
  mutation CreateWallet($userId: IntegerId!, $currency: String!) {
    createWallet(userId: $userId, currency: $currency) {
      id
      userId
      currency
      balance
    }
  }
  """

  describe "@create_wallet" do
    test "create wallet with user id", %{user1: user} do
      assert {:ok, %{data: data}} = Absinthe.run(@create_wallet, Schema,
      variables: %{
        "userId" => user.id,
        "currency" => "AUD"
      })

      assert data["createWallet"]["userId"] === user.id
      assert data["createWallet"]["currency"] === "AUD"
    end
  end

  @send_money """
  mutation SendMoney(
    $recipientId: IntegerId!,
    $recipientCurrency: String!,
    $senderId: IntegerId!,
    $senderCurrency: String!,
    $amount: Decimal!
  ) {
    sendMoney(
      recipientId: $recipientId,
      recipientCurrency: $recipientCurrency,
      senderId: $senderId,
      senderCurrency: $senderCurrency,
      amount: $amount
    ) {
      id
      userId
      currency
      balance
    }
  }
  """

  describe "@send_money" do
    test "send money from user to another user", %{user1: sender, user2: recipient} do
      sender_wallet = Enum.at(sender.wallets, 0)
      recipient_wallet = Enum.at(recipient.wallets, 0)

      transaction_amount = Decimal.new("100")
      {:ok, %{data: data}} = Absinthe.run(@send_money, Schema,
      variables: %{
        "senderId" => sender.id,
        "senderCurrency" => to_string(sender_wallet.currency),
        "recipientId" => recipient.id,
        "recipientCurrency" => to_string(recipient_wallet.currency),
        "amount" => to_string(transaction_amount)
      })

      updated_sender_balance = Decimal.new(data["sendMoney"]["balance"])

      assert updated_sender_balance === Decimal.sub(sender_wallet.balance, transaction_amount)
    end
  end

end
