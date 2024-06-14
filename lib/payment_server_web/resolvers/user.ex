defmodule PaymentServerWeb.Resolvers.User do
  alias PaymentServer.Accounts

  def find(%{email: email}, _) do
    Accounts.find_user(%{email: email})
  end

  def find(%{id: id}, _) do
    id = String.to_integer(id)
    Accounts.find_user(%{id: id})
  end

  def find(_, _) do
    {:error, ErrorMessage.bad_request("Specify arguments")}
  end

  def all(params, _) do
    Accounts.list_users(params)
  end

  def create(params, _) do
    Accounts.create_user(params)
  end
end
