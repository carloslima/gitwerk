defmodule GitWerk.Accounts.UserKey do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  alias __MODULE__
  alias GitWerk.Accounts.User
  alias GitWerk.EnumUserKeyTypes


  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "accounts_user_keys" do

    field :title, :string
    field :key, :string
    field :type, EnumUserKeyTypes
    field :used_at, Timex.Ecto.DateTime

    belongs_to :user, User
    timestamps()
  end


  @doc false
  def changeset(%UserKey{} = user_key, attrs) do
    user_key
    |> cast(attrs, [:type, :key, :title])
    |> validate_required([:type, :key, :title])
    |> validate_format(:key, ~r/^(ssh-rsa|ssh-dss|ssh-ed25519|ecdsa-sha2-nistp256|ecdsa-sha2-nistp384|ecdsa-sha2-nistp521)/)
  end
end
