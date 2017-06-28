defmodule Gitwerk.Web.RepositoryController do
  use Gitwerk.Web, :controller

  alias GitwerkData.Projects
  alias GitwerkData.Accounts

  action_fallback Gitwerk.Web.FallbackController

  def index(conn, _) do
    render conn, "index.json", repositories: []
  end

  def create(conn, %{"repository" => repo_params}) do
    #params = %{name: repo_params["name"], privacy: repo_params["privacy"]}
    with user <- Guardian.Plug.current_resource(conn),
         {:ok, repo} <- Projects.create(user, repo_params) do
           conn
           |> put_status(:created)
           |> render("repository.json", repository: repo)
    end
  end

  def show(conn, %{"user_id" => user_id, "repository_name" => repository_name}) do
    auth_user = Guardian.Plug.current_resource(conn)
    with user when not is_nil(user) <- Accounts.get_user_by!(%{username: user_id}),
         repo when not is_nil(repo) <- Projects.get_repository_by!(%{user_id: user.id, name: repository_name}),
         true <- GitwerkData.Authorization.can?(auth_user, :show, repo) do
           conn
           |> render("repository.json", repository: repo)
    else
      _ -> {:error, :not_found}
    end
  end
end
