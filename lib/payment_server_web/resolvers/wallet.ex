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

end
