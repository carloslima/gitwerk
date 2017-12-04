defmodule GitWerkWeb.CodeController do
  use GitWerkWeb, :controller
  require Logger

  action_fallback GitWerkWeb.FallbackController

  plug GitWerkWeb.LoadRepositoryPlug, repo_slug: "repository_id"

  alias GitWerk.Projects

  def entries(conn, params) do
    file_list(conn, params)
  end
  def file_list(conn, params) do
    path = params["path"] || ""
    conn = assign(conn, :tree_path, path)
    with {:ok, file_list} <- Projects.list_repository_files(conn.assigns.repository, params["tree_id"], path) do
      render(conn, "index.json-api", data: file_list)
    else
      error ->
        Logger.warn "failed to fetch the file list with error : #{inspect error}"
        {:error, :not_found}
    end

  end
end
