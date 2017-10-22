defmodule GitWerkWeb.RepositoryView do
  use GitWerkWeb, :view
  alias GitWerkWeb.RepositoryView

  def render("index.json", %{repositories: repositories}) do
    render_many(repositories, RepositoryView, "repository.json")
  end

  def render("repository.json", %{repository: repository}) do
    %{
      id: repository.id,
      name: repository.name,
      namespace: repository.user.username,
      privacy: repository.privacy,
    }
  end
end
