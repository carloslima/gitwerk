defmodule Gitwerk.Repo.Migrations.CreateGitwerk.Accounts.User do
  use Ecto.Migration

  def change do
    create table(:accounts_users, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :username, :string
      add :email, :string
      add :password_hash, :string

      timestamps()
    end

    create unique_index(:accounts_users, [:email])
    create unique_index(:accounts_users, [:username])
  end
end
