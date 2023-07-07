use Mix.Config

config :ecto_position, EctoPosition.Test.Repo,
  adapter: Ecto.Adapters.Postgres,
  pool: Ecto.Adapters.SQL.Sandbox,
  database: "ecto_position_test",
  username: "postgres",
  password: "postgres"

config :ecto_position, ecto_repos: [EctoPosition.Test.Repo]

config :logger, :console, level: :error
