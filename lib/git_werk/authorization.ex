defmodule GitWerk.Authorization do
  @moduledoc false
  alias GitWerk.Accounts.User
  alias GitWerk.Projects.Repository

  def can?(_, :show, %Repository{privacy: :public}) do
    :ok
  end

  def can?(%User{id: user_id}, :show, %Repository{user_id: user_id, privacy: :private}) do
    :ok
  end

  def can?(%User{id: user_id}, :clone, %Repository{user_id: user_id}) do
    :ok
  end

  def can?(%User{id: user_id}, :push, %Repository{user_id: user_id}) do
    :ok
  end

  def can?(nil, :show, %Repository{user_id: _, privacy: :private}) do
    {:error, :unauthorized}
  end

  def can?(_, _, _) do
    {:error, :no_match}
  end
end
