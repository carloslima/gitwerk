defmodule GitWerk.Accounts.User do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset
  alias GitWerk.Accounts.{User, UserKey}


  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "accounts_users" do
    field :email, :string
    field :password_hash, :string
    field :username, :string
    field :password, :string, virtual: true
    field :jwt_token, :string, virtual: true

    has_many :user_keys, UserKey
    timestamps()
  end

  @doc false
  def changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:username, :email, :password_hash])
    |> validate_required([:email, :username])
    |> validate_length(:username, min: 5)
    |> update_change(:username, &(String.downcase(&1 || "")))
    |> update_change(:email, &(String.downcase(&1 || "")))
    |> validate_format(:email, ~r/@/)
    |> validate_format(:username, ~r/^[a-z0-9_-]*$/)
    |> unique_constraint(:username)
    |> unique_constraint(:email)

  end

  @doc false
  def registration_changeset(%User{} = user, attrs) do
    user
    |> changeset(attrs)
    |> cast(attrs, [:password])
    |> validate_required([:password])
    |> validate_length(:password, min: 6, max: 100)
    |> validate_confirmation(:password, message: "does not match password!")
    |> put_pass_hash
  end

  defp put_pass_hash(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: pass}} ->
        changeset
        |> put_change(:password, nil)
        |> put_change(:password_hash, Comeonin.Bcrypt.hashpwsalt(pass))
      _ ->
        changeset
    end
  end

  @doc """
  Validates password for given user
  """
  def validate_password(%__MODULE__{} = user, password) do
    case Comeonin.Bcrypt.checkpw(password, user.password_hash) do
      true -> {:ok, user}
      false -> invalid_user_changeset()
    end
  end

  def validate_password(_, _password) do
    Comeonin.Bcrypt.dummy_checkpw
    invalid_user_changeset()
  end

  defp invalid_user_changeset do
    ch = %User{}
         |> change()
         |> add_error(:username, "username or password is wrong")
    {:error, ch}
  end
end
