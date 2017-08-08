defmodule GitWerk.Projects.Git do
  alias GitWerk.Projects.Repository
  alias GitWerk.Accounts.User

  def create(%User{} = user, %Repository{} = repo) do
    opts = Application.get_env(:gitwerk_data, GitWerk.Projects.Git)
    opts[:git_home_dir]
    repo_loc = "#{opts[:git_home_dir]}/#{user.username}/#{repo.name}"
    #Geef.Repository.init(repo_loc, true)
    {:ok, self()}
  end
end
