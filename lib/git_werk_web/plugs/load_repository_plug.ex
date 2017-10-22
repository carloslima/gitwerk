defmodule GitWerkWeb.LoadRepositoryPlug do
  @moduledoc """
  Validate and load repository into conn.assigns.repository

  if repository is not found or current user doesn't have access
  return `nil`
  """

  import Plug.Conn

  alias GitWerk.{Projects, Accounts, Authorization}

  @doc false
  def init(opts), do: opts

  @doc false
  def call(conn, _) do
    username = conn.params["user_slug"] || ""
    repository_name = conn.params["repository_slug"] || conn.params["slug"]  || ""
    auth_user = Accounts.get_current_user(conn)
    with user when not is_nil(user) <- Accounts.get_user_by(%{username: username}),
         repo when not is_nil(repo) <- Projects.get_repository_by(%{user_id: user.id, name: repository_name}),
         :ok <- Authorization.can?(auth_user, :show, repo) do
           conn
           |> assign(:repository, %{repo | user: user})
    else
      _ -> conn
           |> assign(:repository, nil)
    end
  end
end
