use Mix.Config

# Configure your database
config :gitwerk_data, GitwerkData.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "",
  database: "gitwerk_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

