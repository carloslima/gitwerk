defmodule Gitwerk.Web.RepositoryControllerTest do
  use Gitwerk.Web.ConnCase

  @valid_password "123456"
  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "list of repositories", %{conn: conn} do
    user = user_fixture(password: @valid_password)
    login_conn = post conn, session_path(conn, :create), user: %{username: user.username, password: @valid_password}
    session = json_response(login_conn, 201)
    conn = conn
           |> put_req_header("authorization", "Bearer #{session["jwt_token"]}")
    conn = get conn, repository_path(conn, :index)

    assert json_response(conn, 201)
  end

  @tag :skip
  test "create repository for user", %{conn: conn} do
    #user = user_fixture(password: @valid_password)
    #login_conn = post conn, session_path(conn, :create), user: %{username: user.username, password: @valid_password}
    #session = json_response(login_conn, 201)
    #conn = conn
    #|> put_req_header("authorization", "Bearer #{token}")
    conn = post conn, repository_path(conn, :create), repository: %{name: "my repo", privacy: :public}

    assert json_response(conn, 201)
  end
end
