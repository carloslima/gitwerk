defmodule GitWerkWeb.UserKeyView do
  use GitWerkWeb, :view

  alias __MODULE__

  def render("index.json", %{user_keys: keys}) do
    render_many(keys, UserKeyView, "key.json")
  end

  def render("key.json", %{user_key: key}) do
    %{
      id: key.id,
      title: key.title,
    }
  end
end
