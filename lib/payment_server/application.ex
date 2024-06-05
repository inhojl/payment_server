defmodule PaymentServer.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  alias PaymentServer.ExchangeRateServer
  alias PaymentServer.Config

  @impl true
  def start(_type, _args) do
    children = [
      PaymentServerWeb.Telemetry,
      PaymentServer.Repo,
      {DNSCluster, query: Application.get_env(:payment_server, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: PaymentServer.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: PaymentServer.Finch},
      # Start a worker by calling: PaymentServer.Worker.start_link(arg)
      # {PaymentServer.Worker, arg},
      # Start to serve requests, typically the last entry
      PaymentServerWeb.Endpoint,
      {Absinthe.Subscription, PaymentServerWeb.Endpoint},
    ] ++ init_exchange_rate_servers(Mix.env())

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: PaymentServer.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    PaymentServerWeb.Endpoint.config_change(changed, removed)
    :ok
  end


defp init_exchange_rate_servers(:test), do: []
defp init_exchange_rate_servers(_) do
  for from_currency <- Config.currencies(),
      to_currency <- Config.currencies(),
      from_currency != to_currency do
    ExchangeRateServer.child_spec(from_currency, to_currency)
  end
end

end
