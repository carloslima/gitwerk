use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :git_werk, GitWerkWeb.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :git_werk, GitWerk.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: System.get_env("DATABASE_USERNAME") || "postgres",
  password: System.get_env("DATABASE_PASSWORD") || "postgres",
  database: System.get_env("DATABASE_DBNAME") || "git_werk_test",
  hostname: System.get_env("DATABASE_HOST") || "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :comeonin, :bcrypt_log_rounds, 4
config :comeonin, :pbkdf2_rounds, 1

config :git_werk, GitWerk.Projects.Git,
  git_home_dir:  Path.join([Path.expand("."), "priv", "test"])

config :git_werk, GitWerkGuts.SshAuthorizedKeys,
  authorized_keys_file: Path.join([Path.expand("."), "priv", "test", ".ssh", "authorized_keys2"])

config :git_werk, GitWerkGuts.SshServer,
  system_dir: Path.join([Path.expand("."), "priv/test/ssh_keys/"])
