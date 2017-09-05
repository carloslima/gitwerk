defmodule Mix.Tasks.StartSshd do
  def run(_) do
  end
end
defmodule SshRunner do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, [], [])
  end
  def init(_) do
    :erlang.send_after(1000, __MODULE__, :runssh)
    {:ok, nil}
  end

  def handle_info(:runssh, state) do
    IO.inspect "running sshd................."
    cmd = "/usr/sbin/sshd"
    System.cmd(cmd, ["-D"])
    {:noreply, state}
  end
end

