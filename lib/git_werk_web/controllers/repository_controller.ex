defmodule GitWerkWeb.RepositoryController do
  use GitWerkWeb, :controller

  alias GitWerk.Projects
  alias GitWerk.Accounts

  action_fallback GitWerkWeb.FallbackController

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

  def show(conn, %{"user_slug" => username, "slug" => repository_name}) do
    auth_user = Guardian.Plug.current_resource(conn)
    with user when not is_nil(user) <- Accounts.get_user_by!(%{username: username}),
         repo when not is_nil(repo) <- Projects.get_repository_by!(%{user_id: user.id, name: repository_name}),
         true <- GitWerk.Authorization.can?(auth_user, :show, repo) do
           conn
           |> render("repository.json", repository: %{repo | user: user})
    else
      _ -> {:error, :not_found}
    end
  end
end
