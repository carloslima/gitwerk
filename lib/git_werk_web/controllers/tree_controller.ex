defmodule GitWerkWeb.TreeController do
  use GitWerkWeb, :controller
  require Logger

  action_fallback GitWerkWeb.FallbackController

  plug GitWerkWeb.LoadRepositoryPlug, repo_slug: "repository_id"

  alias GitWerk.Projects

  def show(conn, params) do
    path = params["path"] || ""
    conn = assign(conn, :tree_path, path)
    with {:ok, file_list} <- Projects.list_repository_files(conn.assigns.repository, params["tree_id"], path) do
      tree = %{id: params["tree_id"], name: params["tree_id"], tree_entries: file_list, type: "tree"}
      render(conn, "index.json-api", data: tree)
    else
      error ->
        Logger.warn "failed to fetch the file list with error : #{inspect error}"
        {:error, :not_found}
    end
  end
end
