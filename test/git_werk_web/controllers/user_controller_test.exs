defmodule GitWerkWeb.UserControllerTest do
  use GitWerkWeb.ConnCase

  alias GitWerk.Accounts

  @create_attrs %{email: "some@email.com", password: "some password_hash", username: "some_username"}
  @invalid_attrs %{email: nil, password_hash: nil, username: nil}

  def fixture(:user) do
    {:ok, user} = Accounts.create_user(@create_attrs)
    user
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "creates user and renders user when data is valid", %{conn: conn} do
    user_req =%{data: %{type: "users", attributes: @create_attrs}}
    conn = post conn, user_path(conn, :create), user_req
    new_user = json_response(conn, 201)
    assert %{"data" => %{"id" => id}} = new_user
    assert new_user["data"]["attributes"]

    conn = get conn, user_path(conn, :show, id)
    user = json_response(conn, 200)
    assert %{"data" => %{"id" => ^id}} = user
  end

  test "does not create user and renders errors when data is invalid", %{conn: conn} do
    user_req =%{data: %{type: "users", attributes: @invalid_attrs}}
    conn = post conn, user_path(conn, :create), user_req
    assert json_response(conn, 422)["errors"] != %{}
  end
end
