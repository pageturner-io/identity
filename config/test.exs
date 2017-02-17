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

# Configure Guardian
config :guardian, Guardian,
  allowed_algos: ["HS512"],
  verify_module: Guardian.JWT,
  issuer: "PageturnerIdentity.#{Mix.env}",
  ttl: { 30, :days },
  verify_issuer: true,
  secret_key: "tMNnxbTs4Ave+n3D9vEO92kBZSpQq/D/njTbeElV+bRdTSMhfnqdOLfTqHKvbkZ1",
  serializer: Identity.Auth.GuardianSerializer

# Configure Hivent
config :identity, :hivent, Hivent.Memory

# Print only warnings and errors during test
config :logger, level: :warn
