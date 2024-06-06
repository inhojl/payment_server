defmodule PaymentServerWeb.Schema.Subscriptions.TransactionTest do
  use PaymentServerWeb.SubscriptionCase

  import PaymentServer.AccountsFixtures, only: [users_fixture: 0]

  setup do
    users_fixture()
  end

  @send_money """
  mutation SendMoney($recipientId: IntegerId!, $recipientCurrency: String!, $senderId: IntegerId!, $senderCurrency: String!, $amount: Decimal!) {
    sendMoney(recipientId: $recipientId, recipientCurrency: $recipientCurrency, senderId: $senderId, senderCurrency: $senderCurrency, amount: $amount) {
      id
      userId
      currency
      balance
    }
  }
  """

  @transaction_subscription """
  subscription Transaction($userId: IntegerId!) {
    transaction(userId: $userId) {
      walletId
      userId
      currency
      transactionAmount
      transactionType
    }
  }
  """

  describe "@transaction_subscription" do
    test "sends transaction payload when user sends money", %{socket: socket, user1: sender, user2: recipient} do

      ref = push_doc socket, @transaction_subscription, variables: %{"userId" => sender.id}
      assert_reply ref, :ok, %{subscriptionId: subscription_id}

      sender_wallet = Enum.at(sender.wallets, 0)
      recipient_wallet = Enum.at(recipient.wallets, 0)
      transaction_amount = Decimal.new("100")

      ref = push_doc socket, @send_money, variables: %{
        "senderId" => sender.id,
        "senderCurrency" => to_string(sender_wallet.currency),
        "recipientId" => recipient.id,
        "recipientCurrency" => to_string(recipient_wallet.currency),
        "amount" => to_string(transaction_amount)
      }

      updated_sender_balance = Decimal.sub(sender_wallet.balance, transaction_amount) |> to_string
      assert_reply ref, :ok, reply
      assert %{
        data: %{"sendMoney" => %{
          "id" => sender_wallet_id,
          "userId" => sender_user_id,
          "currency" => sender_currency,
          "balance" => ^updated_sender_balance
        }}
      } = reply

      transaction_amount = to_string(transaction_amount)
      assert_push "subscription:data", data
      assert %{
        subscriptionId: ^subscription_id,
        result: %{
          data: %{
            "transaction" => %{
              "walletId" => ^sender_wallet_id,
              "userId" => ^sender_user_id,
              "currency" => ^sender_currency,
              "transactionAmount" => ^transaction_amount,
              "transactionType" => "credit"
            }
          }
        }
      } = data
    end
  end

end
