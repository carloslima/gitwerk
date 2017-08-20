defmodule GitWerkWeb.CodeView do
  use GitWerkWeb, :view

  def render("file_list.json", %{file_list: file_list}) do
    file_list
    |> Enum.map(fn f ->
      %{name: f.name, type: f.type}
    end)
  end
end
