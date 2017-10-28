# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :git_werk,
  ecto_repos: [GitWerk.Repo]

# Configures the endpoint
config :git_werk, GitWerkWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "YYSwsxcb/i50eldMT8cx5Vb5UD7FZhcKTQ06huUm2dXLUCjY5/OdkkFnCqxwzes2",
  render_errors: [view: GitWerkWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: GitWerk.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :guardian, Guardian,
  allowed_algos: ["HS512"], # optional
  verify_module: Guardian.JWT,  # optional
  issuer: "Gitwerk",
  ttl: { 30, :days },
  allowed_drift: 2000,
  verify_issuer: true, # optional
  secret_key: "AB2Np8HznjWl14z+5GtekuZNWDIFEB0UNMRVueH0LzA0NMIEEfMysdG2VdGK/kC6",
  serializer: GitWerkWeb.Auth.GuardianSerializer

config :phoenix, :format_encoders,
  "json-api": Poison

config :mime, :types, %{
  "application/vnd.api+json" => ["json-api"]
}
# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
