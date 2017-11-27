defmodule GitWerkWeb.RepositoryController do
  use GitWerkWeb, :controller

  alias GitWerk.Projects
  alias GitWerk.Projects.Tree

  action_fallback GitWerkWeb.FallbackController

  plug GitWerkWeb.LoadRepositoryPlug when action in [:show]

  def index(conn, _) do
    render conn, "index.json-api", data: []
  end

  def create(conn, %{"repository" => repo_params}) do
    with user <- Guardian.Plug.current_resource(conn),
         {:ok, project} <- Projects.create(user, repo_params) do
           conn
           |> put_status(:created)
           |> render("show.json-api", data: %{project.repo| user: user})
    else
      {:error, :repo, repo_ch, _} -> {:error, repo_ch}
      e -> e
    end
  end

  def show(conn, _) do
    with repo when not is_nil(repo) <- conn.assigns.repository do
      conn
      |> render("show.json-api", data: %{repo| trees: [%{id: "master", type: "branch", repo: repo}]})
    else
      _ -> {:error, :not_found}
    end
  end
end
