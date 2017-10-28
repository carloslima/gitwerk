defmodule GitWerkWeb.SessionControllerTest do
  use GitWerkWeb.ConnCase

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "create session for exist user", %{conn: conn} do
    user = fixture(:user)
    conn = post conn, session_path(conn, :create), %{grant_type: "password",username: user.username, password: "some password_hash"}
    logged_in_user = json_response(conn, 201)
    assert logged_in_user["access_token"]
  end

  test "does not create user and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, session_path(conn, :create), %{grant_type: "password", username: "us", password: "passss"}
    assert json_response(conn, 422)["errors"] != %{}
  end
end
