defmodule GitWerkGuts.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [])
  end

  def init(_opts) do
    conf = Application.get_env(:git_werk, GitWerkGuts.SshAuthorizedKeys)
    children = [
      worker(GitWerkGuts.SshServer, []),
      worker(GitWerkGuts.SshAuthorizedKeys, [[authorized_keys_file: conf[:authorized_keys_file]], :self_name]),
    ]
    supervise(children, strategy: :one_for_one)
  end
end
