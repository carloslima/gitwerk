defmodule Gitwerk.Web.UserController do
  use Gitwerk.Web, :controller

  alias GitwerkData.Accounts
  alias GitwerkData.Accounts.User

  action_fallback Gitwerk.Web.FallbackController

  def create(conn, %{"user" => user_params}) do
    with {:ok, %User{} = user} <- Accounts.create_user(user_params) do
      new_conn = Guardian.Plug.api_sign_in(conn, user)
      jwt_token = Guardian.Plug.current_token(new_conn)
      user = %{user| jwt_token: jwt_token}
      conn
      |> put_status(:created)
      |> put_resp_header("location", user_path(conn, :show, user))
      |> render("show.json", user: user)
    end
  end

  def show(conn, %{"slug" => id}) do
    user = Accounts.get_user!(id)
    render(conn, "show.json", user: user)
  end
end
