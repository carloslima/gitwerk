defmodule GitwerkData.Authorization do
  alias GitwerkData.Accounts.User
  alias GitwerkData.Projects.Repository

  def can?(_, :show, %Repository{privacy: :public}) do
    false
  end

  def can?(%User{id: user_id}, :show, %Repository{user_id: user_id, privacy: :private}) do
    true
  end

  def can?(nil, :show, %Repository{user_id: user_id, privacy: :private}) do
    false
  end
end
