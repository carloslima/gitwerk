defmodule GitWerk.Projects.Repository do
  use Ecto.Schema
  import Ecto.Changeset
  alias GitWerk.Projects.Repository
  alias GitWerk.Accounts.User
  alias GitWerk.EnumRepositoryPrivacies


  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "projects_repositories" do
    field :name, :string
    field :privacy, EnumRepositoryPrivacies

    belongs_to :user, User

    field :repo, :any, virtual: true
    timestamps()
  end

  @doc false
  def changeset(%Repository{} = repo, attrs) do
    repo
    |> force_cast(attrs, [:name, :user_id, :privacy])
    |> validate_required([:name, :user_id, :privacy])
    |> validate_format(:name, ~r/^[a-z0-9_-]*$/)
    |> foreign_key_constraint(:user_id)
    |> unique_constraint(:name, name: :projects_repositories_user_id_name_index)
  end

  def force_cast(repo, attrs, allowed) do
    to_atom_value = fn
      {k, v} when is_binary(k) ->
        {to_atom_if_possible(k), v}
      {k, v} ->
        {k, v}
    end
    attrs = attrs
            |> Enum.map(&(to_atom_value.(&1)))
            |> Enum.into(%{})
    cast(repo, attrs, allowed)
  end

  defp to_atom_if_possible(string) do
    try do
      String.to_existing_atom(string)
    rescue
      _ -> string
    end
  end
end

