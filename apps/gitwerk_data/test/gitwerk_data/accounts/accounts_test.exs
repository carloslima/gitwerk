defmodule GitwerkData.AccountsTest do
  use GitwerkData.DataCase

  alias GitwerkData.Accounts

  describe "users" do
    alias GitwerkData.Accounts.User

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

    test "valid user with valid password" do
      user = user_fixture()
      assert {:ok, _} = Accounts.validate_user_password(user.username, "some password_hash")
    end

    test "valid user with invalid password" do
      user = user_fixture()
      assert {:error, _} = Accounts.validate_user_password(user.username, "wrong")
    end

    test "list_users/0 returns all users" do
      user = user_fixture()
      assert Accounts.list_users() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
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

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      assert {:ok, user} = Accounts.update_user(user, @update_attrs)
      assert %User{} = user
      assert user.email == "some@updated.com"
      assert user.password_hash == "some updated password_hash"
      assert user.username == "some_updated_username"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_attrs)
      assert user == Accounts.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Accounts.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end
  end
end
