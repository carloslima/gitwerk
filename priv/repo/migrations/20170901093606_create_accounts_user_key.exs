defmodule GitWerk.Repo.Migrations.CreateAccountsUserKey do
  use Ecto.Migration

  def change do
    GitWerk.EnumUserKeyTypes.create_type
    create table(:accounts_user_keys, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :title, :string
      add :key, :text
      add :type, :key_type

      add :used_at, :naive_datetime, null: true

      add :user_id, references(:accounts_users, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:accounts_user_keys, [:user_id])
  end
end
