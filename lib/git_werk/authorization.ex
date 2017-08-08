defmodule GitWerk.Authorization do
  alias GitWerk.Accounts.User
  alias GitWerk.Projects.Repository

  def can?(_, :show, %Repository{privacy: :public}) do
    false
  end

  def can?(%User{id: _user_id}, :show, %Repository{user_id: user_id, privacy: :private}) do
    true
  end

  def can?(nil, :show, %Repository{user_id: user_id, privacy: :private}) do
    false
  end
end
