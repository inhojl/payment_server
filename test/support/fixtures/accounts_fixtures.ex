defmodule PaymentServer.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `PaymentServer.Accounts` context.
  """

  alias PaymentServer.Accounts

  def users_fixture do
    {:ok, user1} =
      Accounts.create_user(%{
        email: "user1@email.com",
        wallets: [
          %{
            currency: :USD,
            balance: Decimal.new("100")
          },
          %{
            currency: :KRW,
            balance: Decimal.new("100")
          }
        ]
      })

    {:ok, user2} =
      Accounts.create_user(%{
        email: "user2@email.com",
        wallets: [
          %{
            currency: :USD,
            balance: Decimal.new("100")
          },
          %{
            currency: :KRW,
            balance: Decimal.new("100")
          }
        ]
      })

    {:ok, user3} =
      Accounts.create_user(%{
        email: "user3@email.com",
        wallets: [
          %{
            currency: :USD,
            balance: Decimal.new("100")
          },
          %{
            currency: :KRW,
            balance: Decimal.new("100")
          }
        ]
      })

    %{user1: user1, user2: user2, user3: user3}
  end

  def exchange_rate_fixture do
    Decimal.new("2")
  end
end
