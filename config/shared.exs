import Config

config :joblite_core,
  ecto_repos: [Joblite.Repo],
  start_repo: config_env() != :test

config :joblite_core, Joblite.Repo,
  migration_primary_key: [name: :id, type: :binary_id],
  migration_foreign_key: [type: :binary_id],
  pool_size: 5

if config_env() != :prod do
  database = if config_env() == :test, do: "joblite_test", else: "joblite_dev"

  config :joblite_core, Joblite.Repo,
    url: System.get_env("DATABASE_URL") ||
      "ecto://joblite:joblite_local_only@localhost:5432/#{database}"
end

if config_env() == :test do
  config :joblite_core, Joblite.Repo, pool: Ecto.Adapters.SQL.Sandbox
end
