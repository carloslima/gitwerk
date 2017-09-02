defmodule GitWerkWeb.UserKeyController do
  use GitWerkWeb, :controller
  alias GitWerk.Accounts


  action_fallback GitWerkWeb.FallbackController

  def index(conn, %{"user_slug" => req_username}) do
    current_user = Accounts.get_current_user(conn)
    with :ok <- validate_user(current_user.username, req_username),
         keys <- Accounts.list_keys_for(current_user) do
           conn
           |> render("index.json", user_keys: keys)
    end
  end

  def create(conn, %{"user_slug" => req_username, "key" => key_params}) do
    current_user = Accounts.get_current_user(conn)
    with :ok <- validate_user(current_user.username, req_username),
         {:ok, key} <- Accounts.create_key(current_user, key_params) do
      conn
      |> put_status(:created)
      |> render("key.json", user_key: key)
    end
  end

  defp validate_user(usern, usern), do: :ok
  defp validate_user(_, _), do: {:error, :forbidden}
end
