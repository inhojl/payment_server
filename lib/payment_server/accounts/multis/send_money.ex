defmodule PaymentServer.Accounts.Multis.SendMoney do
  alias Ecto.Multi
  alias PaymentServer.Accounts.TransactionType
  alias PaymentServer.Repo
  alias PaymentServer.Accounts
  alias PaymentServer.Accounts.Wallet
  alias PaymentServer.ExchangeRateServer

  @moduledoc """
  This module handles sending money between wallets.

  It performs a series of operations in a multi-step transaction, including locking wallets,
  retrieving exchange rates, updating wallet balances, and broadcasting transactions.

  When modifying this module, it is important to maintain the order of operations
  to ensure data integrity and consistency.
  """


  @doc """
  Executes a multi-step transaction to send money from one wallet to another.

  This function initializes the transaction, locks the involved wallets,
  retrieves the necessary exchange rates, updates the wallet balances,
  and broadcasts the transactions.

  ## Parameters

    - sender_wallet: Wallet.t
    - recipient_wallet: Wallet.t
    - transaction_amount: Decimal.t

  ## Returns

    - `{:ok, Wallet.t}` on success, where Wallet.t is the updated sender_wallet
    - `{:error, ErrorMessage.t}` on failure

  ## Note

  The order of operations in this function is crucial for maintaining data consistency.
  """
  def multi(%Wallet{} = sender_wallet, %Wallet{} = recipient_wallet, %Decimal{} = transaction_amount) do
    Multi.new()
    |> init_multi_changes(sender_wallet, recipient_wallet, transaction_amount)
    |> lock_wallets()
    |> get_exchange_rate()
    |> update_wallets()
    |> Repo.transaction()
    |> case do
      {:ok, changes} -> broadcast_transactions_and_extract_sender_wallet(changes)
      {:error, failed_operation, failed_value, changes_so_far} -> handle_error(__MODULE__, __ENV__.function, failed_operation, failed_value, changes_so_far)
    end
  end


  defp init_multi_changes(multi, sender_wallet, recipient_wallet, transaction_amount) do
    multi
    |> Multi.put(:sender_wallet, sender_wallet)
    |> Multi.put(:recipient_wallet, recipient_wallet)
    |> Multi.put(:transaction_amount, transaction_amount)
  end

  defp lock_wallets(multi) do
    multi
    |> Multi.one(:find_sender_wallet, fn %{sender_wallet: sender_wallet} ->
      Wallet.lock_by_user_id_and_currency(sender_wallet.user_id, sender_wallet.currency)
    end)
    |> Multi.one(:find_recipient_wallet, fn %{recipient_wallet: recipient_wallet} ->
      Wallet.lock_by_user_id_and_currency(recipient_wallet.user_id, recipient_wallet.currency)
    end)
  end

  defp get_exchange_rate(multi) do
    Multi.run(multi, :get_exchange_rate, fn _, %{find_recipient_wallet: recipient_wallet, find_sender_wallet: sender_wallet} ->
      if sender_wallet.currency === recipient_wallet.currency do
        {:ok, Decimal.new("1")}
      else
        case ExchangeRateServer.get_exchange_rate(sender_wallet.currency, recipient_wallet.currency) do
          {:ok, exchange_rate} -> {:ok, exchange_rate}
          {:error, error} -> {:error, error}
        end
      end
    end)
  end

  defp update_wallets(multi) do
    multi
    |> Multi.update(:update_sender_wallet, fn %{find_sender_wallet: sender_wallet, transaction_amount: transaction_amount} ->
      updated_balance = Decimal.sub(sender_wallet.balance, transaction_amount)
      Wallet.changeset(sender_wallet, %{balance: updated_balance})
    end)
    |> Multi.update(:update_recipient_wallet, fn %{find_recipient_wallet: recipient_wallet, get_exchange_rate: exchange_rate, transaction_amount: transaction_amount} ->
      converted_transaction_amount = Decimal.mult(transaction_amount, exchange_rate)
      updated_balance = Decimal.add(recipient_wallet.balance, converted_transaction_amount)
      Wallet.changeset(recipient_wallet, %{balance: updated_balance})
    end)
  end

  defp broadcast_transactions_and_extract_sender_wallet(%{
    update_sender_wallet: sender_wallet,
    update_recipient_wallet: recipient_wallet,
    transaction_amount: transaction_amount,
    get_exchange_rate: exchange_rate
  }) do
    {:ok, sender_transaction} = Accounts.create_transaction(sender_wallet, transaction_amount, TransactionType.credit())
    {:ok, recipient_transaction} = Accounts.create_transaction(recipient_wallet, Decimal.mult(transaction_amount, exchange_rate), TransactionType.debit())

    Absinthe.Subscription.publish(PaymentServerWeb.Endpoint, sender_transaction, transaction: "transaction:#{sender_wallet.user_id}")
    Absinthe.Subscription.publish(PaymentServerWeb.Endpoint, recipient_transaction, transaction: "transaction:#{recipient_wallet.user_id}")

    {:ok, sender_wallet}
  end

  defp handle_error(module, {function_name, arity}, failed_operation, failed_value, changes_so_far) do
    message = "[#{module}.#{function_name}/#{arity}] Multi transaction failed - #{failed_operation}: #{failed_value}"
    {:error, ErrorMessage.internal_server_error(message, changes_so_far)}
  end

end
