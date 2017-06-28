defmodule Gitwerk.Web.RepositoryView do
  use Gitwerk.Web, :view
  alias Gitwerk.Web.RepositoryView

  def render("index.json", %{repositories: repositories}) do
    render_many(repositories, RepositoryView, "repository.json")
  end

  def render("repository.json", %{repository: repository}) do
    %{id: repository.id}
  end
end