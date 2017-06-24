defmodule Gitwerk.Web.UserControllerTest do
  use Gitwerk.Web.ConnCase

  alias GitwerkData.Accounts

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
    conn = post conn, user_path(conn, :create), user: @create_attrs
    new_user = json_response(conn, 201)
    assert %{"id" => id} = new_user
    assert new_user["jwt_token"]

    conn = get conn, user_path(conn, :show, id)
    user = json_response(conn, 200)
    assert %{"id" => ^id} = user
  end

  test "does not create user and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, user_path(conn, :create), user: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end
end
