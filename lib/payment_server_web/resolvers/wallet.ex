defmodule PaymentServerWeb.Resolvers.Wallet do

  alias PaymentServer.Accounts.Wallet
  alias PaymentServer.Accounts

  def find(%{user_id: user_id, currency: currency}, _) do
    user_id = String.to_integer(user_id)

    Accounts.find_wallet(%{user_id: user_id, currency: currency})
  end

  def find(%{id: id}, _) do
    id = String.to_integer(id)

    Accounts.find_wallet(%{id: id})
  end

  def all(params, _) do
    Accounts.list_wallets(params)
  end

  def create(params, _) do
    Accounts.create_wallet(params)
  end

  def send_money(%{
    recipient_id: recipient_id,
    recipient_currency: recipient_currency,
    sender_id: sender_id,
    sender_currency: sender_currency,
    amount: amount}, _) do

    amount = Decimal.new(amount)
    sender_wallet = %Wallet{user_id: sender_id, currency: sender_currency}
    recipient_wallet = %Wallet{user_id: recipient_id, currency: recipient_currency}

    Accounts.send_money(sender_wallet, recipient_wallet, amount)
  end

  def calculate_total_worth(%{user_id: user_id, currency: currency}, _) do
    user_id = String.to_integer(user_id)

    Accounts.calculate_total_worth(user_id, currency)
  end

end
