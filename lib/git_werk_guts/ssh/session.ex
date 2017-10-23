defmodule GitWerkGuts.SshSession do
  defstruct public_key: nil, username: nil

  alias __MODULE__

  def new(attrs \\ %{}) do
    session = struct(SshSession, attrs)
    with {:ok, _} <- Registry.register(GitWerkGuts.SshSession, self(), session) do
      {:ok, session}
    end
  end

  def update(%SshSession{} = attrs) do
    with {new_value, old_value} <- Registry.update_value(GitWerkGuts.SshSession, self(), fn _ -> attrs end) do
      if new_value.public_key != old_value.public_key do
        Registry.register(GitWerkGuts.SshSession, new_value.public_key, self())
      end
      {:ok, new_value}
    end
  end

  def get(pid \\ nil) do
    pid = pid || self()
    with [{_, value}] = Registry.lookup(GitWerkGuts.SshSession, pid) do
      {:ok, value}
    end
  end

  def get_by_key(public_key) do
    with [{_, pid}] = Registry.lookup(GitWerkGuts.SshSession, public_key) do
      get(pid)
    end
  end
end
