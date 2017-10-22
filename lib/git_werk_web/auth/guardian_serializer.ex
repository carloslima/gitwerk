defmodule GitWerkWeb.Auth.GuardianSerializer do
  @moduledoc false
  @behaviour Guardian.Serializer

  alias GitWerk.Accounts.User
  alias GitWerk.Repo
  def for_token(%User{} = user), do: {:ok, "User:#{user.id}"}
  def for_token(_), do: {:error, "Unknown resource type"}

  def from_token("User:" <> id), do: {:ok, Repo.get(User, id)}
  def from_token(_), do: {:error, "Unknown resource type"}
end

