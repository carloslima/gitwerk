defmodule GitWerkGuts.SshTest do
  use GitWerk.DataCase
  alias GitWerkGuts.Ssh

  describe "ssh command" do
    test "validates ssh command" do
      assert Ssh.valid_command?("git-upload-pack 'username/repo.git'")
      assert Ssh.valid_command?("git-receive-pack 'username/repo.git'")
      refute Ssh.valid_command?("whatever command")
      refute Ssh.valid_command?(" whatever command")
      refute Ssh.valid_command?(" ")
      refute Ssh.valid_command?("")
    end

    test "exports command and repository" do
      {:ok, cmd} = Ssh.parse_command("git-upload-pack '/username/repo.git'")

      assert cmd.command == "git-upload-pack"
      assert cmd.username =~ "username"
      assert cmd.repository =~ "repo"


      {:ok, _} = Ssh.parse_command("git-receive-pack '/username/repo.git'")
    end

    test "returns error if command is not a git command" do
      assert :error = Ssh.parse_command("whatever '/username/repo.git'")
    end
  end

  describe "checks if user can interact with repos" do
    setup [:user_fixture_context, :project_fixture_context, :user_key_fixture_context]

    test "owner is allowed to clone & push repo", %{user: user, user_key: user_key, project: repo} do
      {:ok, cmd} = Ssh.parse_command("git-upload-pack '/#{user.username}/#{repo.name}.git'")
      assert Ssh.is_allowed?(cmd, user_key.id)
      {:ok, cmd} = Ssh.parse_command("git-receive-pack '/#{user.username}/#{repo.name}.git'")
      assert Ssh.is_allowed?(cmd, user_key.id)

      {:ok, full_cmd} = Ssh.get_git_command("git-upload-pack '/#{user.username}/#{repo.name}.git'", user_key.id)
      conf = Application.get_env(:git_werk, GitWerk.Projects.Git)
      assert full_cmd == "git-upload-pack #{conf[:git_home_dir]}/#{user.username}/#{repo.name}.git"
    end

    test "owner with deleted key is not allowed to access to repo", %{user: user, project: repo} do
      {:ok, cmd} = Ssh.parse_command("git-upload-pack '/#{user.username}/#{repo.name}.git'")
      refute Ssh.is_allowed?(cmd, "bdfd4f77-8678-4c8b-8bf6-05251246a3a5")
    end

    test "random user is not allowed to clone others repo", %{user: user, project: repo} do
      a_user = fixture(:user)
      a_user_key = fixture(:user_key, %{user: a_user})
      {:ok, cmd} = Ssh.parse_command("git-upload-pack '/#{user.username}/#{repo.name}.git'")
      refute Ssh.is_allowed?(cmd, a_user_key.id)
    end
  end
end
