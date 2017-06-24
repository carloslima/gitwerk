use Mix.Config

config :gitwerk_data, ecto_repos: [GitwerkData.Repo]

import_config "#{Mix.env}.exs"
