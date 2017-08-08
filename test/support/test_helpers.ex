defmodule GitWerk.TestHelpers do
  alias GitWerk.Accounts
  alias GitWerk.Projects

  def user_fixture(attrs \\ %{}) do
    user = rand_str()
    valid_user = %{email: "#{user}@email.com", password: "some password_hash", username: user}
    {:ok, user} =
      attrs
      |> Enum.into(valid_user)
      |> Accounts.create_user()
    user
  end

  def repository_fixture(attrs \\ %{}) do
    repo_name = rand_str()
    valid_repo = %{name: repo_name, privacy: :private, user_id: nil}
    {:ok, repository} =
      attrs
      |> Enum.into(valid_repo)
      |> Projects.create_repository()

    repository
  end

  def conn_with_auth(conn, user) do
    new_conn = Guardian.Plug.api_sign_in(conn, user)
    jwt_token = Guardian.Plug.current_token(new_conn)
    conn
    |> Plug.Conn.put_req_header("authorization", "Bearer #{jwt_token}")
  end

  defp rand_str do
    Base.encode16(:crypto.strong_rand_bytes(9))
    |> String.downcase
  end
end