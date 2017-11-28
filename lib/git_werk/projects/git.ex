defmodule GitWerk.Projects.Git do
  @moduledoc false
  alias GitWerk.Projects.Repository
  alias GitWerk.Accounts.User

  alias Gixir.Repository, as: GitRepo
  alias Gixir.{Branch, Tree, Commit}

  def open(username, repo_name) do
    {:ok, _gpid} =
      username
      |> repo_path(repo_name)
      |> Gixir.Repository.open
  end

  def create(%User{} = user, %Repository{} = repo) do
    {:ok, gpid} =
      user.username
      |> repo_path(repo.name)
      |> Gixir.Repository.init_at(bare: true)
    {:ok, gpid}
  end

  def ls_files(pid, reference) do
    ls_files(pid, reference, "")
  end

  def ls_files(pid, reference, path) when byte_size(reference) == 40 do
    tree_lookup = fn pid, tree, path ->
      if path == "" do
        Tree.lookup(pid, tree.oid)
      else
        Tree.lookup_bypath(pid, tree, path)
      end
    end
    with {:ok, commit} <- Commit.lookup(pid, reference),
         {:ok, tree} <- tree_lookup.(pid, commit.tree, path) do
           {:ok, tree.entries}
    end
  end

  def ls_files(pid, reference, path) do
    tree_lookup = fn pid, tree, path ->
      if path == "" do
        Tree.lookup(pid, tree.oid)
      else
        Tree.lookup_bypath(pid, tree, path)
      end
    end
    with {:ok, branch} <- GitRepo.lookup_branch(pid, reference, :local),
         {:ok, commit} <- Branch.target(branch),
         {:ok, tree} <- tree_lookup.(pid, commit.tree, path) do
           {:ok, tree.entries}
    end
  end

  defp repo_path(username, repo_name) do
    opts = Application.get_env(:git_werk, GitWerk.Projects.Git)
    opts[:git_home_dir]
    "#{opts[:git_home_dir]}/#{username}/#{repo_name}.git"
  end
end
