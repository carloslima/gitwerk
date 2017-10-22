defmodule GitWerk.Projects do
  @moduledoc """
  The boundary for the Projects system.
  """

  import Ecto.Query, warn: false
  alias GitWerk.Repo

  alias GitWerk.Projects.Git
  alias GitWerk.Projects.Repository
  alias GitWerk.Accounts.User

  @doc """
  Creates project with all required resources
  """
  def create(%User{} = user, attrs \\ %{}) do
    attrs = attrs |> Map.put(:user_id, user.id)
    Ecto.Multi.new
    |> Ecto.Multi.insert(:repo, create_repository_changeset(attrs))
    |> Ecto.Multi.run(:project_git_dir, fn %{repo: repo} -> Git.create(user, repo) end)
    |> Repo.transaction
  end

  @doc """
  Returns the list of files for given repository for given reference and path
  """
  def list_repository_files(repository, reference, path) do
    user = repository.user
    {:ok, pid} = Git.open(user.username, repository.name)
    Git.ls_files(pid, reference, path)
  end

  @doc """
  Returns the list of repositories.

  ## Examples

      iex> list_repositories()
      [%Repository{}, ...]

  """
  def list_repositories do
    Repo.all(Repository)
  end

  @doc """
  Gets a single repository.

  Raises `Ecto.NoResultsError` if the Repository does not exist.

  ## Examples

      iex> get_repository!(123)
      %Repository{}

      iex> get_repository!(456)
      ** (Ecto.NoResultsError)

  """
  def get_repository!(id), do: Repo.get!(Repository, id)

  def get_repository_by(condition), do: Repo.get_by(Repository, condition)

  @doc """
  Creates a repository.

  ## Examples

      iex> create_repository(%{field: value})
      {:ok, %Repository{}}

      iex> create_repository(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_repository(attrs \\ %{}) do
    attrs
    |> create_repository_changeset
    |> Repo.insert()
  end

  def create_repository_changeset(attrs \\ %{}) do
    %Repository{}
    |> Repository.changeset(attrs)
  end

  @doc """
  Updates a repository.

  ## Examples

      iex> update_repository(repository, %{field: new_value})
      {:ok, %Repository{}}

      iex> update_repository(repository, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_repository(%Repository{} = repository, attrs) do
    repository
    |> Repository.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Repository.

  ## Examples

      iex> delete_repository(repository)
      {:ok, %Repository{}}

      iex> delete_repository(repository)
      {:error, %Ecto.Changeset{}}

  """
  def delete_repository(%Repository{} = repository) do
    Repo.delete(repository)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking repository changes.

  ## Examples

      iex> change_repository(repository)
      %Ecto.Changeset{source: %Repository{}}

  """
  def change_repository(%Repository{} = repository) do
    Repository.changeset(repository, %{})
  end
end
