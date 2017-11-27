defmodule GitWerkWeb.TreeView do
  use GitWerkWeb, :view
  use JaSerializer.PhoenixView

  attributes [:tree_type]

  has_many :tree_entries, serializer: GitWerkWeb.CodeView, link: :get_link, include: true, identifiers: :always

  def get_link(tree, conn) do
    "/api/v1/repositories/#{conn.assigns.repository.id}/trees/#{tree.id}/entries"
  end

  def id(tree, _), do: tree[:name] || tree[:id]

  def tree_type(tree, _) do
    tree.type
  end

end
