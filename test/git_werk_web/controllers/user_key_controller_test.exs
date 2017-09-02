defmodule GitWerkWeb.UserKeyControllerTest do
  use GitWerkWeb.ConnCase


  @create_attrs %{type: :ssh, title: "my key", key: "ssh-rsa asdasdas"}
  @invalid_attrs %{type: :bar, title: "", key: "wrong for now"}

  describe "while user is logged in ->" do
    setup [:user_fixture_context, :conn_accept_json_context, :conn_with_auth_context]

    test "adds ssh key", %{conn: conn, user: user} do
      conn = post conn, user_setting_key_path(conn, :create, user.username), key: @create_attrs
      assert json_response(conn, :created)
    end

    test "adds invalid ssh key", %{conn: conn, user: user} do
      conn = post conn, user_setting_key_path(conn, :create, user.username), key: @invalid_attrs
      res =  json_response(conn, :unprocessable_entity)
      assert Enum.count(res["errors"]) == 3, "there should be 3 invalid data"
    end

    test "is not allowed to create key for others", %{conn: conn} do
      other_user = fixture(:user)
      conn = post conn, user_setting_key_path(conn, :create, other_user.username), key: @create_attrs
      assert json_response(conn, :forbidden)
    end
  end


  describe "when anonymous sends request ->" do
    setup [:user_fixture_context, :conn_accept_json_context]

    test "doesn't allow the user tp create key for others", %{conn: conn, user: user} do
      conn = post conn, user_setting_key_path(conn, :create, user.username), key: @invalid_attrs
      assert json_response(conn, :unauthorized)
    end
  end
end
