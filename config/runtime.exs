import Config

# Production composition root for the core release.
#
# The release carries no configuration values: the database is addressed by
# the environment only. The sibling frontend release owns its own runtime
# file (frontend/config/runtime.exs) because a release may not import files
# that live outside the release itself.
#
# DATABASE_URL              required - PostgreSQL connection URL
# DATABASE_SSL              optional - verify-full (default) | require | disable
# DATABASE_CA_CERT          required by verify-full - CA bundle path
# DATABASE_SSL_SERVER_NAME  required by verify-full - expected certificate name
# POOL_SIZE                 optional - Repo pool size (default 5)

if config_env() == :prod do
  # A missing variable must name itself: the boot error is the only feedback
  # an operator gets before the container exits.
  fetch_env = fn name ->
    case System.get_env(name) do
      nil ->
        raise "missing required environment variable #{name} " <>
                "(see backend/deploy/env.example for the deployment reference)"

      value ->
        value
    end
  end

  database_url = fetch_env.("DATABASE_URL")

  # DATABASE_SSL selects the PostgreSQL transport policy. The default
  # verify-full pins the server against a supplied CA bundle; managed
  # platforms that terminate database TLS without shipping a CA file set
  # DATABASE_SSL=require, which keeps the connection encrypted without
  # certificate pinning. An unknown value fails the boot instead of
  # silently downgrading.
  database_ssl =
    case System.get_env("DATABASE_SSL", "verify-full") do
      "verify-full" ->
        [
          verify: :verify_peer,
          cacertfile: fetch_env.("DATABASE_CA_CERT"),
          server_name_indication: String.to_charlist(fetch_env.("DATABASE_SSL_SERVER_NAME"))
        ]

      "require" ->
        [verify: :verify_none]

      "disable" ->
        false

      other ->
        raise "unsupported DATABASE_SSL value: #{inspect(other)} " <>
                "(expected verify-full | require | disable)"
    end

  config :joblite_core, Joblite.Repo,
    url: database_url,
    pool_size: String.to_integer(System.get_env("POOL_SIZE", "5")),
    ssl: database_ssl

  # A release logs at :info by default. Query logging stays off in production:
  # statement parameters can carry candidate data.
  config :logger, level: :info
end
