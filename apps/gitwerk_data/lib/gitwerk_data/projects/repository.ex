defmodule GitwerkData.Projects.Repository do
  use Ecto.Schema
  import Ecto.Changeset
  alias GitwerkData.Projects.Repository
  alias GitwerkData.EnumRepositoryPrivacies


  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "projects_repositories" do
    field :name, :string
    field :privacy, EnumRepositoryPrivacies
    field :user_id, Ecto.UUID

    field :repo, :any, virtual: true
    timestamps()
  end

  @doc false
  def changeset(%Repository{} = repo, attrs) do
    repo
    |> cast(attrs, [:name, :user_id, :privacy])
    |> validate_required([:name, :user_id, :privacy])
    |> validate_format(:name, ~r/^[a-z0-9_-]*$/)
    |> foreign_key_constraint(:user_id)
  end
end

