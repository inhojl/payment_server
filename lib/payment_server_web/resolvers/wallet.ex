defmodule PaymentServerWeb.Resolvers.Wallet do

  alias PaymentServer.Accounts


  def find(%{id: id}, _) do
    id = String.to_integer(id)

    Accounts.find_wallet(%{id: id})
  end

  def all(params, _) do
    Accounts.list_wallets(params)
  end


end
