defmodule TreeSerializer do
  #TODO: should move it to GitWerkWeb.TreeView
  use JaSerializer
  attributes [:tree_type]

  has_many :tree_entries, link: :get_link

  def get_link(tree, __) do
    "/api/v1/repositories/#{tree.repo.id}/trees/#{tree.id}/entries"
  end

  def tree_type(tree, _) do
    tree.type
  end
end

defmodule GitWerkWeb.RepositoryView do
  use GitWerkWeb, :view
  use JaSerializer.PhoenixView

  attributes [:name, :privacy, :namespace, :slug, :permissions]

  has_many :trees, type: "trees", serializer: TreeSerializer, link: "/repositories/:id/trees", include: true

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
