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

currencies = [
  "AED",
  "AFN",
  "ALL",
  "AMD",
  "ANG",
  "AOA",
  "ARS",
  "AUD",
  "AWG",
  "AZN",
  "BAM",
  "BBD",
  "BDT",
  "BGN",
  "BHD",
  "BIF",
  "BMD",
  "BND",
  "BOB",
  "BRL",
  "BSD",
  "BTN",
  "BWP",
  "BZD",
  "CAD",
  "CDF",
  "CHF",
  "CLF",
  "CLP",
  "CNH",
  "CNY",
  "COP",
  "CUP",
  "CVE",
  "CZK",
  "DJF",
  "DKK",
  "DOP",
  "DZD",
  "EGP",
  "ERN",
  "ETB",
  "EUR",
  "FJD",
  "FKP",
  "GBP",
  "GEL",
  "GHS",
  "GIP",
  "GMD",
  "GNF",
  "GTQ",
  "GYD",
  "HKD",
  "HNL",
  "HRK",
  "HTG",
  "HUF",
  "ICP",
  "IDR",
  "ILS",
  "INR",
  "IQD",
  "IRR",
  "ISK",
  "JEP",
  "JMD",
  "JOD",
  "JPY",
  "KES",
  "KGS",
  "KHR",
  "KMF",
  "KPW",
  "KRW",
  "KWD",
  "KYD",
  "KZT",
  "LAK",
  "LBP",
  "LKR",
  "LRD",
  "LSL",
  "LYD",
  "MAD",
  "MDL",
  "MGA",
  "MKD",
  "MMK",
  "MNT",
  "MOP",
  "MRO",
  "MRU",
  "MUR",
  "MVR",
  "MWK",
  "MXN",
  "MYR",
  "MZN",
  "NAD",
  "NGN",
  "NOK",
  "NPR",
  "NZD",
  "OMR",
  "PAB",
  "PEN",
  "PGK",
  "PHP",
  "PKR",
  "PLN",
  "PYG",
  "QAR",
  "RON",
  "RSD",
  "RUB",
  "RUR",
  "RWF",
  "SAR",
  "SBDf",
  "SCR",
  "SDG",
  "SDR",
  "SEK",
  "SGD",
  "SHP",
  "SLL",
  "SOS",
  "SRD",
  "SYP",
  "SZL",
  "THB",
  "TJS",
  "TMT",
  "TND",
  "TOP",
  "TRY",
  "TTD",
  "TWD",
  "TZS",
  "UAH",
  "UGX",
  "USD",
  "UYU",
  "UZS",
  "VND",
  "VUV",
  "WST",
  "XAF",
  "XCD",
  "XDR",
  "XOF",
  "XPF",
  "YER",
  "ZAR",
  "ZMW",
  "ZWL"
]

insert_fake_wallet = fn id ->
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
|> Enum.each(&insert_fake_wallet.(&1))

IO.puts("Inserted 1 fake wallet per fake user")

half_count = div(length(ids), 2)

ids
|> Enum.take(half_count)
|> Enum.each(&insert_fake_wallet.(&1))

IO.puts("Inserted 1 more fake wallet for half the users inserted")
