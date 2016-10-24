use Mix.Config

# Configure Guardian
config :guardian, Guardian,
  allowed_algos: ["HS512"],
  verify_module: Guardian.JWT,
  issuer: "PageturnerIdentity.#{Mix.env}",
  ttl: { 30, :days },
  verify_issuer: true,
  secret_key: "tMNnxbTs4Ave+n3D9vEO92kBZSpQq/D/njTbeElV+bRdTSMhfnqdOLfTqHKvbkZ1",
  serializer: Identity.Auth.GuardianSerializer
