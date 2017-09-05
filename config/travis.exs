use Mix.Config

# Configure your database
config :git_werk, GitWerk.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "",
  database: "git_werk_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :git_werk, GitWerk.Projects.Git,
  git_home_dir:  Path.join([Path.expand("."), "priv", "test"])

config :git_werk, GitWerkGuts.SshAuthorizedKeys,
  authorized_keys_file: Path.join([Path.expand("."), "priv", "test", ".ssh", "authorized_keys2"])
