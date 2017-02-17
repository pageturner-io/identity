# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :identity,
  ecto_repos: [Identity.Repo]

# Configures the endpoint
config :identity, Identity.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "xG7FPlfMwyzDhmHY+It0Kek1zz57Il/VU1XCUEFILr8MIMb87J+fid8oEutFGfC7",
  render_errors: [view: Identity.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Identity.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Configure Auth
config :identity, Identity.Auth,
  cookie: [domain: "localhost",
    max_age: 60*60*24*14,
    name: "pageturner_identity"]

# Configure Guardian
config :guardian, Guardian,
  allowed_algos: ["HS512"],
  verify_module: Guardian.JWT,
  issuer: "PageturnerIdentity.#{Mix.env}",
  ttl: { 30, :days },
  verify_issuer: true,
  secret_key: {:system, "GUARDIAN_SECRET_KEY"},
  serializer: Identity.Auth.GuardianSerializer,
  hooks: Identity.Auth.Hooks

config :guardian_db, GuardianDb,
  repo: Identity.Repo,
  schema_name: "tokens",
  sweep_interval: 120 # minutes

# Configure Ueberauth
config :ueberauth, Ueberauth,
  providers: [
    github: {Ueberauth.Strategy.Github, [
      uid_field: "email",
      default_scope: "user,repo"]}
  ]

config :ueberauth, Ueberauth.Strategy.Github.OAuth,
  client_id: System.get_env("GITHUB_CLIENT_ID"),
  client_secret: System.get_env("GITHUB_CLIENT_SECRET")

# Configure Hivent
config :identity, :hivent, Hivent
config :hivent,
  backend: :redis,
  endpoint: System.get_env("HIVENT_URL"),
  partition_count: 4,
  client_id: "identity"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
