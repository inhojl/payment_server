alias PaymentServer.Config
alias PaymentServer.Accounts.Wallet
alias PaymentServer.Accounts.User
alias PaymentServer.Repo

import Ecto.Query, warn: false
Application.ensure_all_started(:faker)

ids =
  1..100
  |> Enum.map(fn _ ->
    fake_user = %User{
      email: Faker.Internet.email()
    }

    %User{id: id} = Repo.insert!(fake_user)
    id
  end)

IO.puts("100 fake users have been created")

currencies = Config.currencies()

insert_fake_wallet = fn id, used_currencies ->
  available_currencies = currencies -- used_currencies

  fake_wallet = %Wallet{
    user_id: id,
    currency: Enum.random(currencies),
    balance:
      1..100_000
      |> Enum.random()
      |> Decimal.new()
      |> Decimal.div(Decimal.new(100))
  }

  Repo.insert!(fake_wallet)
end

ids
|> Enum.each(&insert_fake_wallet.(&1, []))

IO.puts("Inserted 1 fake wallet per fake user")

half_count = div(length(ids), 2)

ids
|> Enum.take(half_count)
|> Enum.each(fn id ->
  # Retrieve already used currencies for this user
  used_currencies = Repo.all(from w in Wallet, where: w.user_id == ^id, select: w.currency)
  insert_fake_wallet.(id, used_currencies)
end)

IO.puts("Inserted 1 more fake wallet for half the users inserted")
