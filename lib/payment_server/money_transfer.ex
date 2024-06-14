defmodule PaymentServer.MoneyTransfer do
  alias Ecto.Multi
  alias PaymentServer.Accounts.TransactionType
  alias PaymentServer.Repo
  alias PaymentServer.Accounts
  alias PaymentServer.Accounts.Wallet
  alias PaymentServer.ExchangeRateAgent

  def send_money(
        %Wallet{} = sender_wallet,
        %Wallet{} = recipient_wallet,
        %Decimal{} = transaction_amount
      ) do
    Multi.new()
    |> init_multi_changes(sender_wallet, recipient_wallet, transaction_amount)
    |> lock_wallets()
    |> Multi.run(:get_exchange_rate, &get_exchange_rate_from_sender_to_recipient/2)
    |> update_wallets()
    |> Repo.transaction()
    |> handle_send_money_transaction()
  end

  defp init_multi_changes(multi, sender_wallet, recipient_wallet, transaction_amount) do
    multi
    |> Multi.put(:sender_wallet, sender_wallet)
    |> Multi.put(:recipient_wallet, recipient_wallet)
    |> Multi.put(:transaction_amount, transaction_amount)
  end

  defp lock_wallets(multi) do
    multi
    |> Multi.run(:find_sender_wallet, fn _, %{sender_wallet: wallet} ->
      Accounts.lock_wallet(wallet)
    end)
    |> Multi.run(:find_recipient_wallet, fn _, %{recipient_wallet: wallet} ->
      Accounts.lock_wallet(wallet)
    end)
  end

  defp update_wallets(multi) do
    multi
    |> Multi.update(:update_sender_wallet, fn
      %{
        find_sender_wallet: sender_wallet,
        transaction_amount: transaction_amount
      } ->
        Wallet.changeset(sender_wallet, %{
          balance: Decimal.sub(sender_wallet.balance, transaction_amount)
        })
    end)
    |> Multi.update(:update_recipient_wallet, fn
      %{
        find_recipient_wallet: recipient_wallet,
        get_exchange_rate: exchange_rate,
        transaction_amount: transaction_amount
      } ->
        new_balance =
          transaction_amount
          |> Decimal.mult(exchange_rate)
          |> Decimal.add(recipient_wallet.balance)

        Wallet.changeset(recipient_wallet, %{balance: new_balance})
    end)
  end

  defp handle_send_money_transaction(result) do
    case result do
      {:ok, changes} ->
        broadcast_transactions_and_extract_sender_wallet(changes)

      {:error, _, %ErrorMessage{} = error, _} ->
        {:error, error}

      {:error, failed_operation, failed_value, changes_so_far} ->
        handle_error(__MODULE__, __ENV__.function, failed_operation, failed_value, changes_so_far)
    end
  end

  defp handle_error(
         module,
         {function_name, arity},
         failed_operation,
         failed_value,
         changes_so_far
       ) do
    message =
      "[#{module}.#{function_name}/#{arity}] Multi transaction failed - #{failed_operation}: #{failed_value}"

    {:error, ErrorMessage.internal_server_error(message, {:internal, changes_so_far})}
  end

  def get_exchange_rate_from_sender_to_recipient(_, %{
        find_recipient_wallet: recipient_wallet,
        find_sender_wallet: sender_wallet
      }) do
    get_exchange_rate_from_sender_to_recipient(sender_wallet, recipient_wallet)
  end

  def get_exchange_rate_from_sender_to_recipient(sender_wallet, recipient_wallet) do
    if sender_wallet.currency === recipient_wallet.currency do
      {:ok, Decimal.new("1")}
    else
      case ExchangeRateAgent.get_exchange_rate(
             sender_wallet.currency,
             recipient_wallet.currency
           ) do
        {:ok, exchange_rate} -> {:ok, exchange_rate}
        {:error, error} -> {:error, error}
      end
    end
  end

  def broadcast_transactions_and_extract_sender_wallet(%{
        update_sender_wallet: sender_wallet,
        update_recipient_wallet: recipient_wallet,
        transaction_amount: transaction_amount,
        get_exchange_rate: exchange_rate
      }) do
    {:ok, sender_transaction} =
      Accounts.create_transaction(sender_wallet, transaction_amount, TransactionType.credit())

    {:ok, recipient_transaction} =
      Accounts.create_transaction(
        recipient_wallet,
        Decimal.mult(transaction_amount, exchange_rate),
        TransactionType.debit()
      )

    Absinthe.Subscription.publish(PaymentServerWeb.Endpoint, sender_transaction,
      transaction: "transaction:#{sender_wallet.user_id}"
    )

    Absinthe.Subscription.publish(PaymentServerWeb.Endpoint, recipient_transaction,
      transaction: "transaction:#{recipient_wallet.user_id}"
    )

    {:ok, sender_wallet}
  end
end
