defmodule GitWerkGuts.SshCommand do
  defstruct command: nil, username: nil, repository: nil
end

defmodule GitWerkGuts.Ssh do
  alias GitWerkGuts.SshCommand
  alias GitWerk.{Accounts, Projects, Authorization}

  @valid_commands ~w{git-upload-pack git-receive-pack git-upload-archive git-lfs-authenticate}
  @commands_to_action %{
    "git-upload-pack" => :clone,
    "git-receive-pack" => :push,
  }

  def valid_command?(""), do: false
  def valid_command?(command) do
    exec =
      command
      |> String.trim
      |> String.split(" ")
      |> Enum.at(0)
    Enum.any? @valid_commands, fn cmd ->
       exec != "" and cmd =~ ~r{^#{exec}}
    end
  end

  def parse_command(command) do
    with true <- valid_command?(command),
         %{"command" => cmd, "username" => username, "repository" => repo_name} <- match_command(command) do
        {:ok, %SshCommand{command: cmd, username: username, repository: repo_name}}
    else
      _ -> :error
    end
  end

  defp match_command(command) do
    Regex.named_captures ~r{(?<command>[a-z\-]*) '/(?<username>.*)/(?<repository>.*).git'}, command
  end

  @doc """
  Checks if user by given key_id is allowed to access
  to request repo
  """
  def is_allowed?(%SshCommand{} = cmd, key_id) do
    with current_user when not is_nil(current_user) <- Accounts.get_user_by(key_id: key_id),
         user when not is_nil(user) <- Accounts.get_user_by(%{username: cmd.username}),
         repo when not is_nil(repo) <- Projects.get_repository_by(%{user_id: user.id, name: cmd.repository}),
         action when not is_nil(action) <- Map.get(@commands_to_action, cmd.command),
         :ok <- Authorization.can?(current_user, action, repo) do
           true
    else
      _ -> false
    end
  end

  @doc """
  Returns full command that we can run to
  interact with git client
  """
  def get_git_command(command, key_id) do
    with {:ok, cmd} <- parse_command(command),
         true <- is_allowed?(cmd, key_id),
         {:ok, repo_full_path} <- find_repo_full_path(cmd.username, cmd.repository) do
           "#{cmd.command} #{repo_full_path}"
    else
      _ -> ""
    end
  end

  defp find_repo_full_path(username, repository) do
    conf = Application.get_env(:git_werk, GitWerk.Projects.Git)
    repo_path = "#{conf[:git_home_dir]}/#{username}/#{repository}.git"
    if File.exists?(repo_path) do
      {:ok, "#{conf[:git_home_dir]}/#{username}/#{repository}.git"}
    else
      {:error, :repo_path_not_found}
    end
  end
end
