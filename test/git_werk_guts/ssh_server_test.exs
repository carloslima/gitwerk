defmodule GitWerkGuts.SshServerTest do
  use GitWerk.DataCase

  alias GitWerkGuts.SshServer

  test "ssh server starts on random open port" do
    ssh_pid = SshServer.ssh_port
    assert ssh_pid
  end
end
