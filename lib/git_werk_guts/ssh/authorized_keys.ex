defmodule GitWerkGuts.SshAuthorizedKeys do
  use GenServer
  defstruct authorized_keys_file: nil

  @ssh_shell_cmd "/home/git/gitwerk/scripts/git-shell-dev.bash"
  @ssh_shell_opt "no-port-forwarding,no-X11-forwarding,no-agent-forwarding,no-pty"

  alias __MODULE__

  def start_link(opts, :self_name) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, [])
  end

  @doc """
  Creates file with chmod 6000
  If directory doesn't exists, creates it recursively
  """
  def create(authorized_keys) do
    dir = Path.dirname(authorized_keys)
    with :ok <- File.mkdir_p(dir),
         :ok <- File.touch(authorized_keys),
         :ok <- File.chmod(authorized_keys, 0o600) do
           :ok
    end
  end

  @doc """
  Adds a key for given key_id to authorized_keys file
  """
  def add(pid, key_id, key) do
    GenServer.cast(pid, {:add, key_id, key})
  end

  def add(key_id, key), do: add(__MODULE__, key_id, key)

  @doc """
  Returns `true` if a key with that id is inside authorized_keys file
  """
  def has?(pid, [key_id: key_id]) do
    GenServer.call(pid, {:has?, {:key_id, key_id}})
  end

  @doc """
  Count items inside authorized_keys_file file
  """
  def remove(pid, [key_id: key_id]) do
    GenServer.cast(pid, {:remove, {:key_id, key_id}})
  end

  @doc """
  Count items inside authorized_keys_file file
  """
  def count(pid) do
    GenServer.call(pid, :count)
  end

  @doc false
  def init([authorized_keys_file: file]) do
    :ok = create(file)
    {:ok, %SshAuthorizedKeys{authorized_keys_file: file}}
  end

  @doc false
  def handle_call(:count, _, state) do
    count =
      state.authorized_keys_file
      |> File.stream!
      |> Enum.reduce(0, fn(_, acc) -> acc + 1 end)
    {:reply, count, state}
  end

  @doc false
  def handle_call({:has?, {:key_id, key_id}}, _, state) do
    {:reply, has_key?(state.authorized_keys_file, key_id), state}
  end

  @doc false
  def handle_cast({:add, key_id, key}, state) do
    if has_key?(state.authorized_keys_file, key_id) == false do
      append_func = fn file ->
        :file.write(file, "command=\"#{@ssh_shell_cmd} #{key_id}\",#{@ssh_shell_opt} #{key}\n")
      end
      File.open(state.authorized_keys_file, [:append, :raw],  append_func)
    end
    {:noreply, state}
  end

  @doc false
  def handle_cast({:remove, {:key_id, key_id}}, state) do
    throw :not_impl
    filename = state.authorized_keys_file
    File.stream!(filename)
    |> Stream.filter(fn line -> not(line =~ key_id) end)
    |> Stream.into(File.stream!(filename))
    |> Stream.run
    {:noreply, state}
  end

  defp has_key?(filename, key_id) do
    filename
    |> File.stream!([], 2048)
    |> Stream.filter(fn line -> line =~ key_id end)
    |> Stream.into([])
    |> Enum.any?
  end
end
