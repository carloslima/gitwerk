defmodule GitWerkWeb.RepositoryView do
  use GitWerkWeb, :view
  use JaSerializer.PhoenixView

  attributes [:name, :privacy, :namespace, :slug, :permissions]

  def permissions(_repo, _conn) do
      [:read]
  end

  def slug(repo, _) do
    "#{repo.user.username}/#{repo.name}"
  end

  def namespace(repo, _) do
    repo.user.username
  end
end
