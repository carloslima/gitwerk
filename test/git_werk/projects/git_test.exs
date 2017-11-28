defmodule GitWerk.GitTest do
  use GitWerk.DataCase

  alias GitWerk.Projects.Git

  test "list files in repo" do
    user = fixture(:user)
    repo = project_fixture(user)
    commit_files(user.username, repo.name)
    {:ok, git} = Git.open(user.username, repo.name)
    {:ok, file_list} = Git.ls_files(git, "master")
    assert length(file_list) == 2

    {:ok, file_list} = Git.ls_files(git, "master", "src")
    assert length(file_list) == 1

    assert {:error, _} = Git.ls_files(git, "master", "somewher")
  end


  def commit_files(username, repo_name) do
    {repo_clone, 0} = System.cmd("mktemp", ["-d"])
    repo_clone = String.trim(repo_clone)
    repo_remote = repo_path(username, repo_name)
    System.cmd("git", ["clone", "--quiet", repo_remote, repo_clone])
    System.cmd("touch", ["README.md"], [cd: repo_clone])
    System.cmd("mkdir", ["src"], [cd: repo_clone])
    System.cmd("touch", ["src/code.src"], [cd: repo_clone])
    System.cmd("git", ["add", "README.md"], [cd: repo_clone])
    System.cmd("git", ["add", "src"], [cd: repo_clone])
    System.cmd("git", ["commit", "-m", "init"], [cd: repo_clone])
    System.cmd("git", ["push", "origin", "HEAD"], [cd: repo_clone])
  end
end
