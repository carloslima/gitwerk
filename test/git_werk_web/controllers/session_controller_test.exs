defmodule GitWerkWeb.SessionControllerTest do
  use GitWerkWeb.ConnCase

  alias GitWerk.Accounts

  @create_attrs %{email: "some@email.com", password: "some password_hash", username: "some_username"}

  def fixture(:user) do
    {:ok, user} = Accounts.create_user(@create_attrs)
    user
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "create session for exist user", %{conn: conn} do
    user = fixture(:user)
    conn = post conn, session_path(conn, :create), user: %{username: user.username, password: "some password_hash"}
    new_user = json_response(conn, 201)
    assert %{"id" => id} = new_user
    assert new_user["jwt_token"]

    conn = get conn, user_path(conn, :show, id)
    user = json_response(conn, 200)
    assert %{"id" => ^id} = user
  end

  test "does not create user and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, session_path(conn, :create), user: %{username: "us", password: "passss"}
    assert json_response(conn, 422)["errors"] != %{}
  end
end
