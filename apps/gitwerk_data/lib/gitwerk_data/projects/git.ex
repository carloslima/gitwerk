defmodule GitwerkData.Projects.Git do
  alias GitwerkData.Projects.Repository
  alias GitwerkData.Accounts.User

  def create(%User{} = user, %Repository{} = repo) do
    opts = Application.get_env(:gitwerk_data, GitwerkData.Projects.Git)
    opts[:git_home_dir]
    repo_loc = "#{opts[:git_home_dir]}/#{user.username}/#{repo.name}"
    Geef.Repository.init(repo_loc, true)
  end
end
