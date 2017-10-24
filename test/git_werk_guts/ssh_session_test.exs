defmodule GitWerkGuts.SshSessionsTest do
  use ExUnit.Case
  alias GitWerkGuts.SshSession

  describe "Sessions" do
    test "set session params to the session" do
      {:ok, session} = SshSession.new
      {:ok, session} = SshSession.update(%{session | user: "boo"})
      {:ok, session} = SshSession.update(%{session | public_key: "ssh-rsa ...."})
      assert session.user == "boo"
      assert session.public_key == "ssh-rsa ...."
      assert {:ok, ^session} = SshSession.get
      assert {:ok, ^session} = SshSession.get(self())
      assert session.user == "boo"
    end
  end
end
