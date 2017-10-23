defmodule GitWerk.Accounts do
  @moduledoc """
  The boundary for the Accounts system.
  """

  import Ecto.Query, warn: false
  alias GitWerk.Repo

  alias GitWerk.Accounts.{User, UserKey}

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    Repo.all(User)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  def get_user_by(key_id: key_id) do
    (from k in UserKey,
    where: k.id == ^key_id,
    preload: [:user])
    |> Repo.one
    |> Kernel.||(%{})
    |> Map.get(:user)
  end

  def get_user_by(condition), do: Repo.get_by(User, condition)

  @doc """
  Gets current user or returns nil
  """
  def get_current_user(conn) do
    Guardian.Plug.current_resource(conn)
  end

  @doc """
    Gets a user if password matches
  """
  def validate_user_password(username, password) do
    User
    |> Repo.get_by(%{username: username})
    |> User.validate_password(password)
  end

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a User.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{source: %User{}}

  """
  def change_user(%User{} = user) do
    User.changeset(user, %{})
  end

  @doc """
  Creates a user key for given user
  """
  def create_key(%User{} =user, attrs \\ %{}) do
    user
    |> Ecto.build_assoc(:user_keys, %{})
    |> UserKey.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Lists keys for given user
  """
  def list_keys_for(%User{} = user) do
    q = from k in UserKey, where: k.user_id == ^user.id
    Repo.all(q)
  end

  @doc """
  Update used_at field
  """
  def update_key(%UserKey{} = key) do
    key
    |> UserKey.key_is_used_ch
    |> Repo.update
  end

  @doc """
  """
  def get_key_by(key: pub_key) do
    Repo.get_by(UserKey, %{key: pub_key})
  end
end
