defmodule PaymentServerWeb.Schema.Mutations.WalletTest do
  alias PaymentServer.Accounts
  alias PaymentServerWeb.Schema
  use PaymentServer.DataCase

  @create_wallet """
  mutation CreateWallet($userId: ID!, $currency: String!) {
    createWallet(userId: $userId, currency: $currency) {
      id
      userId
      currency
      balance
    }
  }
  """

  describe "@create_wallet" do
    test "create wallet with user id" do
      {:ok, user} = Accounts.create_user(%{email: "user1@email.com"})

      assert {:ok, %{data: data}} = Absinthe.run(@create_wallet, Schema,
      variables: %{
        "userId" => user.id,
        "currency" => "USD"
      })

      assert data["createWallet"]["userId"] === to_string(user.id)
      assert data["createWallet"]["currency"] === "USD"
    end
  end

end
