defmodule GitWerkWeb.RepositoryController do
  use GitWerkWeb, :controller

  alias GitWerk.Projects

  action_fallback GitWerkWeb.FallbackController

  plug GitWerkWeb.LoadRepositoryPlug when action in [:show]

  def index(conn, _) do
    render conn, "index.json", repositories: []
  end

  def create(conn, %{"repository" => repo_params}) do
    #params = %{name: repo_params["name"], privacy: repo_params["privacy"]}
    with user <- Guardian.Plug.current_resource(conn),
         {:ok, repo} <- Projects.create(user, repo_params) do
           conn
           |> put_status(:created)
           |> render("repository.json", repository: %{repo| user: user})
    end
  end

  def show(conn, %{"user_slug" => _, "slug" => _}) do
    with repo when not is_nil(repo) <- conn.assigns.repository do
      conn
      |> render("repository.json", repository: repo)
    else
      _ -> {:error, :not_found}
    end
  end
end
