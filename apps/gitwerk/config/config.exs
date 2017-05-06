use Mix.Config

config :gitwerk, ecto_repos: [Gitwerk.Repo]

import_config "#{Mix.env}.exs"
