defmodule GitWerkWeb.UserKeyControllerTest do
  use GitWerkWeb.ConnCase


  @valid_key  "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIi2vk3tcYqQHOecJDULiWwFPYR0tmVRlp9iJGBFdyaq boo@moo.local"
  @create_attrs %{type: :ssh, title: "my key", key: @valid_key}
  @invalid_attrs %{type: :bar, title: "", key: "wrong for now"}

  describe "while user is logged in ->" do
    setup [:user_fixture_context, :conn_accept_json_context, :conn_with_auth_context]

    test "lists ssh keys", %{conn: conn, user: user} do
      fixture(:user_key, %{user: user})
      conn = get conn, user_setting_key_path(conn, :index, user.username)
      assert json_response(conn, 200)
    end

    test "adds ssh key", %{conn: conn, user: user} do
      conn = post conn, user_setting_key_path(conn, :create, user.username), key: @create_attrs
      assert json_response(conn, :created)
    end

    test "adds invalid ssh key", %{conn: conn, user: user} do
      conn = post conn, user_setting_key_path(conn, :create, user.username), key: @invalid_attrs
      res =  json_response(conn, :unprocessable_entity)
      assert Enum.count(res["errors"]) == 4, "there should be 3 invalid data"
    end

    test "is not allowed to create key for others", %{conn: conn} do
      other_user = fixture(:user)
      conn = post conn, user_setting_key_path(conn, :create, other_user.username), key: @create_attrs
      assert json_response(conn, :forbidden)
    end

    test "is not allowed to view others key", %{conn: conn} do
      other_user = fixture(:user)
      conn = get conn, user_setting_key_path(conn, :index, other_user.username)
      assert json_response(conn, :forbidden)
    end

  end


  describe "when anonymous sends request ->" do
    setup [:user_fixture_context, :conn_accept_json_context]

    test "doesn't allow anonymous to create key for others", %{conn: conn, user: user} do
      conn = post conn, user_setting_key_path(conn, :create, user.username), key: @invalid_attrs
      assert json_response(conn, :unauthorized)
    end

    test "doesn't allow anonymous to view others keys", %{conn: conn, user: user} do
      conn = get conn, user_setting_key_path(conn, :index, user.username)
      assert json_response(conn, :unauthorized)
    end

  end
end
