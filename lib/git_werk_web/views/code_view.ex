defmodule GitWerkWeb.CodeView do
  use GitWerkWeb, :view
  use JaSerializer.PhoenixView

  attributes [:name, :id, :entry_type, :path]

  def path(_, conn) do
    conn.assigns.tree_path
  end
  def entry_type(x, _), do: x.type
  def id(x, _) do
    x.oid
  end
  def type, do: "tree-entry"
end
