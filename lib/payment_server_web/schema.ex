defmodule PaymentServerWeb.Schema do
  use Absinthe.Schema

  import_types PaymentServerWeb.Types.User
  import_types PaymentServerWeb.Types.Wallet
  import_types PaymentServerWeb.Types.ExchangeRate
  import_types PaymentServerWeb.Schema.Queries.User
  import_types PaymentServerWeb.Schema.Queries.Wallet
  import_types PaymentServerWeb.Schema.Mutations.User
  import_types PaymentServerWeb.Schema.Mutations.Wallet
  import_types PaymentServerWeb.Schema.Subscriptions.ExchangeRate

  # queries
  query do
    import_fields :user_queries
    import_fields :wallet_queries
  end

  # mutations
  mutation do
    import_fields :user_mutations
    import_fields :wallet_mutations
  end

  # subscriptions
  subscription do
    import_fields :exchange_rate_subscriptions
  end

  def context(ctx) do
    source = Dataloader.Ecto.new(PaymentServer.Repo)
    dataloader = Dataloader.add_source(Dataloader.new(), PaymentServer.Accounts, source)
    Map.put(ctx, :loader, dataloader)
  end

  def plugins do
    [Absinthe.Middleware.Dataloader] ++ Absinthe.Plugin.defaults()
  end

end
