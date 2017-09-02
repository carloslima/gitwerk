defmodule GitWerk.ProjectsTest do
  use GitWerk.DataCase

  alias GitWerk.Projects

  describe "repositories" do
    alias GitWerk.Projects.Repository

    setup [:user_fixture_context]

    @valid_attrs %{name: "repo-name", privacy: :private, user_id: nil}
    @update_attrs %{name: "repo_updated_name", privacy: :public}
    @invalid_attrs %{name: nil, privacy: nil, user_id: nil}

    test "create/1 project with necessary resources", %{user: user} do
      {:ok, repo} = Projects.create(user, @valid_attrs)
      assert repo.repo
    end

    test "list_repositories/0 returns all repositories", %{user: user} do
      repository = repository_fixture(user_id: user.id)
      assert Projects.list_repositories() == [repository]
    end

    test "get_repository!/1 returns the repository with given id", %{user: user} do
      repository = repository_fixture(user_id: user.id)
      assert Projects.get_repository!(repository.id) == repository
    end

    test "create_repository/1 with valid data creates a repository", %{user: user} do
      assert {:ok, %Repository{} = repository} = Projects.create_repository(%{@valid_attrs | user_id: user.id})
      assert repository.name == "repo-name"
      assert repository.privacy == :private
      assert repository.user_id == user.id
    end

    test "create_repository/1 with same name is not allowed", %{user: user} do
      assert {:ok, %Repository{}} = Projects.create_repository(%{@valid_attrs | user_id: user.id})
      assert {:error, changeset} = Projects.create_repository(%{@valid_attrs | user_id: user.id})
      assert errors_on(changeset) == %{name: ["has already been taken"]}
    end

    test "create_repository/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Projects.create_repository(@invalid_attrs)
    end

    test "update_repository/2 with valid data updates the repository", %{user: user} do
      repository = repository_fixture(user_id: user.id)
      assert {:ok, repository} = Projects.update_repository(repository, @update_attrs)
      assert %Repository{} = repository
      assert repository.name == "repo_updated_name"
      assert repository.privacy == :public
      assert repository.user_id == user.id
    end

    test "update_repository/2 with invalid data returns error changeset", %{user: user} do
      repository = repository_fixture(user_id: user.id)
      assert {:error, %Ecto.Changeset{}} = Projects.update_repository(repository, @invalid_attrs)
      assert repository == Projects.get_repository!(repository.id)
    end

    test "delete_repository/1 deletes the repository", %{user: user} do
      repository = repository_fixture(user_id: user.id)
      assert {:ok, %Repository{}} = Projects.delete_repository(repository)
      assert_raise Ecto.NoResultsError, fn -> Projects.get_repository!(repository.id) end
    end

    test "change_repository/1 returns a repository changeset", %{user: user} do
      repository = repository_fixture(user_id: user.id)
      assert %Ecto.Changeset{} = Projects.change_repository(repository)
    end
  end
end

