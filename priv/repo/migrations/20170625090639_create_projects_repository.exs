defmodule GitWerk.Repo.Migrations.CreateGitWerk.Projects.Repository do
  use Ecto.Migration

  def change do
    GitWerk.EnumRepositoryPrivacies.create_type
    create table(:projects_repositories, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :privacy, :privacy
      add :user_id, references(:accounts_users, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:projects_repositories, [:user_id])
    create unique_index(:projects_repositories, [:user_id, :name])
  end
end

