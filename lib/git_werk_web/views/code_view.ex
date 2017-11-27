defmodule GitWerkWeb.CodeView do
  use GitWerkWeb, :view
  use JaSerializer.PhoenixView

  attributes [:name, :id, :entry_type]

  def entry_type(x, _), do: x.type
  def id(x, _) do
    x.oid
  end
  def type, do: "tree-entry"
end
