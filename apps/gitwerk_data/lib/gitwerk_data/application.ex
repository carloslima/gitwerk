defmodule GitwerkData.Application do
  @moduledoc """
  The GitwerkData Application Service.

  The gitwerk system business domain lives in this application.

  Exposes API to clients such as the `Gitwerk.Web` application
  for use in channels, controllers, and elsewhere.
  """
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    Supervisor.start_link([
      worker(GitwerkData.Repo, []),
    ], strategy: :one_for_one, name: GitwerkData.Supervisor)
  end
end