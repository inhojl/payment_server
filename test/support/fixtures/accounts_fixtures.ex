defmodule PaymentServer.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `PaymentServer.Accounts` context.
  """

  @doc """
  Generate a user.
  """
  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        email: "some email"
      })
      |> PaymentServer.Accounts.create_user()

    user
  end

  @doc """
  Generate a wallet.
  """
  def wallet_fixture(attrs \\ %{}) do
    {:ok, wallet} =
      attrs
      |> Enum.into(%{
        balance: "120.5",
        currency: "some currency"
      })
      |> PaymentServer.Accounts.create_wallet()

    wallet
  end


  def exchange_rate_fixture() do
    Decimal.new("2")
  end

end
