defmodule GitWerkWeb.UserKeyView do
  use GitWerkWeb, :view

  def render("key.json", %{key: key}) do
    %{
      id: key.id,
      title: key.title,
    }
  end
end
