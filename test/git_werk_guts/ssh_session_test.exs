defmodule GitWerkGuts.SshSessionsTest do
  use ExUnit.Case
  alias GitWerkGuts.SshSession

  describe "Sessions" do
    test "set session params to the session" do
      {:ok, session} = SshSession.new
      {:ok, session} = SshSession.update(%{session | username: "boo"})
      {:ok, session} = SshSession.update(%{session | public_key: "ssh-rsa ...."})
      assert session.username == "boo"
      assert session.public_key == "ssh-rsa ...."
      assert {:ok, ^session} = SshSession.get
      assert {:ok, ^session} = SshSession.get(self())
      assert session.username == "boo"
      assert {:ok, ^session} = SshSession.get_by_key("ssh-rsa ....")
    end
  end
end
