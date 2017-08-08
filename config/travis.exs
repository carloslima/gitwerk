use Mix.Config

# Configure your database
config :git_werk, GitWerk.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "",
  database: "git_werk_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

