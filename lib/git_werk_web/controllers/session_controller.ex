defmodule GitWerkWeb.SessionController do
  use GitWerkWeb, :controller

  alias GitWerk.Accounts

  action_fallback GitWerkWeb.FallbackController

  def create(conn, %{"user" => user_params}) do
    with {:ok, user} <- Accounts.validate_user_password(user_params["username"], user_params["password"]) do
        new_conn = Guardian.Plug.api_sign_in(conn, user)

        jwt_token = Guardian.Plug.current_token(new_conn)
        user = %{user| jwt_token: jwt_token}
        conn
        |> put_status(:created)
        |> render(GitWerkWeb.UserView, "show.json", user: user)
    end
  end
end
