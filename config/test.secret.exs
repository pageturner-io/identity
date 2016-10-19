use Mix.Config

# Configure your database
config :identity, Identity.Repo,
  adapter: Ecto.Adapters.Postgres,
  url: "postgres://postgres@localhost:32781/identity_test",
  pool: Ecto.Adapters.SQL.Sandbox
