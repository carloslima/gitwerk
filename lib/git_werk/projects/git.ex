defmodule GitWerk.Projects.Git do
  @moduledoc false
  alias GitWerk.Projects.Repository
  alias GitWerk.Accounts.User

  def create(%User{} = user, %Repository{} = repo) do
    {:ok, gpid} =
      user.username
      |> repo_path(repo.name)
      |> Gixir.Repository.init_at(bare: true)
    {:ok, gpid}
  end

  defp repo_path(username, repo_name) do
    opts = Application.get_env(:git_werk, GitWerk.Projects.Git)
    opts[:git_home_dir]
    "#{opts[:git_home_dir]}/#{username}/#{repo_name}.git"
  end
end
