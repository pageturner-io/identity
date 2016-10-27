use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :identity, Identity.Endpoint,
  http: [port: 4001],
  server: false

config :identity, Identity.Repo,
  adapter: Ecto.Adapters.Postgres,
  url: {:system, "DATABASE_URL"},
  pool: Ecto.Adapters.SQL.Sandbox

# Print only warnings and errors during test
config :logger, level: :warn

import_config "test.secret.exs"
