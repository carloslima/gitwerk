use Mix.Config

# Configure your database
config :gitwerk_data, GitwerkData.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "gitwerk_dev",
  hostname: "localhost",
  pool_size: 10

config :gitwerk_data, GitwerkData.Projects.Git,
  git_home_dir:  Path.join([Path.expand("."), "priv", "dev"])
