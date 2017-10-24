defmodule GitWerkGuts.SshSession do
  defstruct public_key: nil, user: nil

  alias __MODULE__

  def new(attrs \\ %{}) do
    session = struct(SshSession, attrs)
    with {:ok, _} <- Registry.register(GitWerkGuts.SshSession, self(), session) do
      {:ok, session}
    end
  end

  def update(%SshSession{} = attrs) do
    with {new_value, old_value} <- Registry.update_value(GitWerkGuts.SshSession, self(), fn _ -> attrs end) do
      {:ok, new_value}
    end
  end

  def get(pid \\ nil) do
    pid = pid || self()
    with [{_, value}] = Registry.lookup(GitWerkGuts.SshSession, pid) do
      {:ok, value}
    end
  end
end
