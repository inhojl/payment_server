defmodule PaymentServer.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias EctoShorts.Actions
  alias PaymentServer.ExchangeRateServer
  alias PaymentServer.Repo
  alias PaymentServer.Accounts.User
  alias PaymentServer.Accounts.Wallet
  alias PaymentServer.Accounts.Transaction
  alias PaymentServer.Accounts.Multis.SendMoney


  def list_users(params) do
    {:ok, Actions.all(User, params)}
  end

  def find_user(params) do
    Actions.find(User, params)
  end

  def create_user(params) do
    Actions.create(User, params)
  end

  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end

  def list_wallets(params) do
    {:ok, Actions.all(Wallet, params)}
  end

  def find_wallet(params) do
    Actions.find(Wallet, params)
  end

  def create_wallet(params) do
    Actions.create(Wallet, params)
  end

  def update_wallet(%Wallet{} = wallet, params) do
    Actions.update(Wallet, wallet, params)
  end

  def delete_wallet(%Wallet{} = wallet) do
    Repo.delete(wallet)
  end

  def change_wallet(%Wallet{} = wallet, attrs \\ %{}) do
    Wallet.changeset(wallet, attrs)
  end

  defdelegate send_money(sender_wallet, recipient_wallet, transaction_amount), to: SendMoney, as: :multi

  def calculate_total_worth(user_id, to_currency) do
    {:ok, %{wallets: wallets}} = find_user(%{id: user_id, preload: :wallets})

    total_worth = Enum.reduce(wallets, Decimal.new("0"), fn %{currency: from_currency, balance: balance}, total_worth ->
      wallet_total = calculate_wallet_total(from_currency, to_currency, balance)
      Decimal.add(total_worth, wallet_total)
    end)

    {:ok, total_worth}
  end

  def calculate_wallet_total(from_currency, to_currency, balance) when from_currency === to_currency, do: balance
  def calculate_wallet_total(from_currency, to_currency, balance) do
      case ExchangeRateServer.get_exchange_rate(from_currency, to_currency) do
        {:ok, exchange_rate} -> Decimal.mult(balance, exchange_rate)
        {:error, error} -> {:error, error}
      end
  end

  def create_transaction(wallet, transaction_amount, type) do
    utc_now = DateTime.utc_now()
    recipient_transaction = %Transaction{
      user_id: wallet.user_id,
      wallet_id: wallet.id,
      currency: wallet.currency,
      transaction_amount: transaction_amount,
      transaction_type: type,
      inserted_at: utc_now,
      updated_at: utc_now
    }
    {:ok, recipient_transaction}
  end
end
