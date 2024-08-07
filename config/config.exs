# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

# Setup stubs
if Mix.env() === :test do
  config :payment_server, alpha_vantage_module: PaymentServer.Support.AlphaVantage
else
  config :payment_server, alpha_vantage_module: PaymentServer.ExternalApis.AlphaVantage
end

config :payment_server,
  currencies: [:USD, :KRW, :AUD]

config :payment_server,
  ecto_repos: [PaymentServer.Repo],
  generators: [timestamp_type: :utc_datetime]

config :ecto_shorts,
  repo: PaymentServer.Repo,
  error_module: EctoShorts.Actions.Error

# Configures the endpoint
config :payment_server, PaymentServerWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [json: PaymentServerWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: PaymentServer.PubSub,
  live_view: [signing_salt: "x1r4UD7Z"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :payment_server, PaymentServer.Mailer, adapter: Swoosh.Adapters.Local

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  payment_server: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.4.0",
  payment_server: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
