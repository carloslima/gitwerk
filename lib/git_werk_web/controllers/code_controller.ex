defmodule GitWerkWeb.CodeController do
  use GitWerkWeb, :controller
  require Logger

  action_fallback GitWerkWeb.FallbackController

  plug GitWerkWeb.LoadRepositoryPlug

  alias GitWerk.Projects

  def file_list(conn, params) do
    path = if params["path"] == [] do
      ""
    else
      Path.join(params["path"])
    end
    with {:ok, file_list} <- Projects.list_repository_files(conn.assigns.repository, params["commit"], path) do
      render(conn, :file_list, file_list: file_list)
    else
      error ->
        Logger.warn "failed to fetch the file list with error : #{inspect error}"
        {:error, :not_found}
    end

  end
end
