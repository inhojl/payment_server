defmodule PaymentServerWeb.Schema do
  use Absinthe.Schema

  import_types PaymentServerWeb.Types.User
  import_types PaymentServerWeb.Types.Wallet
  import_types PaymentServerWeb.Schema.Queries.User

  # queries
  query do
    import_fields :user_queries
  end

  # mutations

  # subscriptions

  def context(ctx) do
    source = Dataloader.Ecto.new(PaymentServer.Repo)
    dataloader = Dataloader.add_source(Dataloader.new(), PaymentServer.Accounts, source)
    Map.put(ctx, :loader, dataloader)
  end

  def plugins do
    [Absinthe.Middleware.Dataloader] ++ Absinthe.Plugin.defaults()
  end

end