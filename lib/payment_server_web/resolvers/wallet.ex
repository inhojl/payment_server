defmodule PaymentServerWeb.Resolvers.Wallet do

  alias PaymentServer.Accounts

  def find(%{user_id: user_id, currency: currency} = params, _) when not is_map_key(params, :id) do
    user_id = String.to_integer(user_id)

    Accounts.find_wallet(%{user_id: user_id, currency: currency})
  end

  def find(%{id: id} = params, _) when not is_map_key(params, :user_id) and not is_map_key(params, :currency) do
    id = String.to_integer(id)

    Accounts.find_wallet(%{id: id})
  end

  def find(_, _) do
    {:error, "Invalid args"}
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
    sender_wallet = %{
      user_id: sender_id,
      currency: sender_currency
    }
    recipient_wallet = %{
      user_id: recipient_id,
      currency: recipient_currency
    }

    Accounts.send_money(sender_wallet, recipient_wallet, amount)
  end

end
