# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :gitwerk_web,
  namespace: Gitwerk.Web,
  ecto_repos: [GitwerkData.Repo]

# Configures the endpoint
config :gitwerk_web, Gitwerk.Web.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "FOzd3c/58duLGAo5OxUaYvYi7I/Ba56f1kCKDsplSh9X5njUfyjSiBLZV7sNiesi",
  render_errors: [view: Gitwerk.Web.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Gitwerk.Web.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :guardian, Guardian,
  allowed_algos: ["HS512"], # optional
  verify_module: Guardian.JWT,  # optional
  issuer: "Gitwerk.Web",
  ttl: { 30, :days },
  allowed_drift: 2000,
  verify_issuer: true, # optional
  secret_key: "AB2Np8HznjWl14z+5GtekuZNWDIFEB0UNMRVueH0LzA0NMIEEfMysdG2VdGK/kC6",
  serializer: Gitwerk.Web.Auth.GuardianSerializer
# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
