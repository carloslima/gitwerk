defmodule GitWerkGuts.SshKeyAuthenticationTest do
  use GitWerk.DataCase

  alias GitWerkGuts.SshKeyAuthentication

  test "get host key for ecdsa-sha2-nistp???" do
    conf = Application.get_env(:git_werk, GitWerkGuts.SshServer)
    {:ok, host_key} = SshKeyAuthentication.host_key(:"ecdsa-sha2-nistp384", conf)
    assert {:ECPrivateKey, 1, _, {:namedCurve, {1, 2, 840, 10045, 3, 1, 7}}, _} = host_key

    {:ok, host_key} = SshKeyAuthentication.host_key(:"ecdsa-sha2-nistp256", conf)
    assert {:ECPrivateKey, 1, _, {:namedCurve, {1, 2, 840, 10045, 3, 1, 7}}, _} = host_key

    {:ok, host_key} = SshKeyAuthentication.host_key(:"ecdsa-sha2-nistp521", conf)
    assert {:ECPrivateKey, 1, _, {:namedCurve, {1, 2, 840, 10045, 3, 1, 7}}, _} = host_key
  end

  test "get host key for ssh-rsa" do
    conf = Application.get_env(:git_werk, GitWerkGuts.SshServer)
    {:ok, host_key} = SshKeyAuthentication.host_key(:"ssh-rsa", conf)
    assert :RSAPrivateKey == elem(host_key, 0)
  end

  test "get host key for rsa-sha2-???" do
    conf = Application.get_env(:git_werk, GitWerkGuts.SshServer)
    {:ok, host_key} = SshKeyAuthentication.host_key(:"rsa-sha2-256", conf)
    assert :RSAPrivateKey == elem(host_key, 0)
  end

  test "get host key for ssh-dss" do
    conf = Application.get_env(:git_werk, GitWerkGuts.SshServer)
    {:ok, host_key} = SshKeyAuthentication.host_key(:"ssh-dss", conf)
    assert :DSAPrivateKey == elem(host_key, 0)
  end

  test "get host key for unknown algorithm" do
    conf = Application.get_env(:git_werk, GitWerkGuts.SshServer)
    assert {:error, :no_host_key_found} = SshKeyAuthentication.host_key(:"bar-mo", conf)
  end
end
