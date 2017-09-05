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
    field :key, :string, default: ""
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
    |> remove_key_comment()
    |> validate_ssh_pub_key(:key)
  end

  @doc false
  def key_is_used_ch(%UserKey{} = user_key) do
    user_key
    |> cast(%{}, [:used_at])
    |> put_change(:used_at, Timex.now)
  end

  defp remove_key_comment(changeset) do
    key =
      changeset.changes[:key]
      |> String.split(" ")
      |> Enum.take(2)
    if changeset.valid? && length(key) >= 2 do
      put_change(changeset, :key, Enum.join(key, " "))
    else
      changeset
    end
  end

  defp validate_ssh_pub_key(changeset, field, _opts \\ []) do
    validate_change changeset, :key, fn :key, key ->
      case GitWerkGuts.SshKey.validate_pub_key(key) do
        :ok -> []
        _ -> [{field, "Invalid SSH public key"}]
      end
    end
  end
end
