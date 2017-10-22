defmodule GitWerk.AccountsTest do
  use GitWerk.DataCase

  alias GitWerk.Accounts

  describe "users" do
    alias GitWerk.Accounts.User
    setup [:user_fixture_context]


    @valid_attrs %{email: "some@email.com", password: "some password_hash", username: "some_username"}
    @update_attrs %{email: "some@updated.com", password_hash: "some updated password_hash", username: "some_updated_username"}
    @invalid_attrs %{email: nil, password_hash: nil, username: nil}

    test "only accept valid username" do
      {:error, changeset} = @valid_attrs
                             |> Map.put(:username, "my invalid user name")
                             |> Accounts.create_user
      assert errors_on(changeset) == %{username: ["has invalid format"]}
    end

    test "doesn't allow two users with same email address" do
      _user1 = Accounts.create_user(Map.put(@valid_attrs, :email, "user1@gitwerk.com"))
      {:error, changeset} = @valid_attrs
                             |> Map.put(:email, "user1@gitwerk.com")
                             |> Map.put(:username, "user2")
                             |> Accounts.create_user
      assert errors_on(changeset) == %{email: ["has already been taken"]}
    end

    test "doesn't allow two users with same username" do
      _user1 = Accounts.create_user(Map.put(@valid_attrs, :username, "user1"))
      {:error, changeset} = @valid_attrs
            |> Map.put(:email, "user2@gitwerk.com")
            |> Map.put(:username, "user1")
            |> Accounts.create_user
      assert errors_on(changeset) == %{username: ["has already been taken"]}
    end

    test "valid user with valid password", %{user: user} do
      assert {:ok, _} = Accounts.validate_user_password(user.username, "some password_hash")
    end

    test "valid user with invalid password", %{user: user} do
      assert {:error, _} = Accounts.validate_user_password(user.username, "wrong")
    end

    test "list_users/0 returns all users", %{user: user} do
      assert Accounts.list_users() == [user]
    end

    test "get_user!/1 returns the user with given id", %{user: user} do
      assert Accounts.get_user!(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Accounts.create_user(@valid_attrs)
      assert user.email == "some@email.com"
      assert user.username == "some_username"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user", %{user: user} do
      assert {:ok, user} = Accounts.update_user(user, @update_attrs)
      assert %User{} = user
      assert user.email == "some@updated.com"
      assert user.password_hash == "some updated password_hash"
      assert user.username == "some_updated_username"
    end

    test "update_user/2 with invalid data returns error changeset", %{user: user} do
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_attrs)
      assert user == Accounts.get_user!(user.id)
    end

    test "delete_user/1 deletes the user", %{user: user} do
      assert {:ok, %User{}} = Accounts.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset", %{user: user} do
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end
  end

  describe "user keys ->" do
    setup [:user_fixture_context]

    @valid_key "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDV7zn4vREzmECWKK8EHaR/uPzMO10KIBHN3fRG0z4l3RjF+ivBwfiFmBdf52gaNfc8Wfs86jRa6MY0MJxWVq9pRyha0sVnUAzVyNBSm5tSeQyYEufTOSk2OGil/flW8F6b0EGsnIMNc37TQNdUHsVNxEw+It3Qym6utrF8AXKTBdWtPia95ynYGER1XAFhZ/nH0dXgqFEaIHDtpKV4FxrvzqST7fwU4O2z7AjOeuvrIkOioFrbS9O8Wa+MekPGE/9neYpbKTNUqTaYSx/Fo4psLvcGLnWcNLk9Gj/6P8SRYThmEtM5YEaN1/yESnIeuCR+XxV0UpCZMkausIe/d2Lv sam@local.local"
    @valid_ecdsa_key "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBLsHHDwJQbNLn5QVupl5wpxiDqcXw1QDUgvEMEL+fMCh8KfxA3mK0FL4Q2CcbjXTvkuuVbKRGWeii+dmy9qbEwM= sam@local"
    @key_title "Office Linux"
    @semi_valid_key "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDV7zn4vREzmECWKK8EHaR sam@local.local"
    @invalid_key "invalid AAAAB3NzaC1yc2EAA user@localhost"

    test "user adds a RSA SSH key", %{user: user} do
      {:ok, _} = Accounts.create_key(user, %{title: @key_title,  key: @valid_key, type: :ssh})
    end

    test "user adds an ECDSA SSH key", %{user: user} do
      {:ok, _} = Accounts.create_key(user, %{title: @key_title,  key: @valid_ecdsa_key, type: :ssh})
    end

    test "updates used_at", %{user: user} do
      {:ok, key} = Accounts.create_key(user, %{title: @key_title,  key: @valid_key, type: :ssh})
      refute key.used_at
      {:ok, key} = Accounts.update_key(key)
      assert key.used_at
    end


    test "uses user struct to set user_id", %{user: hostile_user} do
      innocent_user = fixture(:user)
      {:ok, key} = Accounts.create_key(hostile_user, %{user_id: innocent_user.id, title: @key_title,  key: @valid_key, type: :ssh})
      assert hostile_user.id == key.user_id
    end

    test "doesn't allow to save wrong key", %{user: user} do
      {:error, _} = Accounts.create_key(user, %{title: @key_title,  key: @invalid_key, type: :ssh})
    end

    test "doesn't allow to save semi correct key", %{user: user} do
      {:error, _} = Accounts.create_key(user, %{title: @key_title,  key: @semi_valid_key, type: :ssh})
    end
  end
end
