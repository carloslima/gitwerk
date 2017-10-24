defmodule GitWerkGuts.SshKeyAuthenticationTest do
  use GitWerk.DataCase

  alias GitWerkGuts.SshKeyAuthentication
  alias GitWerk.Accounts

  setup do
    conf = Application.get_env(:git_werk, GitWerkGuts.SshServer)
    {:ok, %{conf: conf}}
  end

  test "get host key for ecdsa-sha2-nistp???", %{conf: conf} do
    {:ok, host_key} = SshKeyAuthentication.host_key(:"ecdsa-sha2-nistp384", conf)
    assert {:ECPrivateKey, 1, _, {:namedCurve, {1, 2, 840, 10045, 3, 1, 7}}, _} = host_key

    {:ok, host_key} = SshKeyAuthentication.host_key(:"ecdsa-sha2-nistp256", conf)
    assert {:ECPrivateKey, 1, _, {:namedCurve, {1, 2, 840, 10045, 3, 1, 7}}, _} = host_key

    {:ok, host_key} = SshKeyAuthentication.host_key(:"ecdsa-sha2-nistp521", conf)
    assert {:ECPrivateKey, 1, _, {:namedCurve, {1, 2, 840, 10045, 3, 1, 7}}, _} = host_key
  end

  test "get host key for ssh-rsa", %{conf: conf} do
    {:ok, host_key} = SshKeyAuthentication.host_key(:"ssh-rsa", conf)
    assert :RSAPrivateKey == elem(host_key, 0)
  end

  test "get host key for rsa-sha2-???", %{conf: conf} do
    {:ok, host_key} = SshKeyAuthentication.host_key(:"rsa-sha2-256", conf)
    assert :RSAPrivateKey == elem(host_key, 0)
  end

  test "get host key for ssh-dss", %{conf: conf} do
    {:ok, host_key} = SshKeyAuthentication.host_key(:"ssh-dss", conf)
    assert :DSAPrivateKey == elem(host_key, 0)
  end

  test "get host key for unknown algorithm", %{conf: conf} do
    assert {:error, :no_host_key_found} = SshKeyAuthentication.host_key(:"bar-mo", conf)
  end

  describe "validates user's public key" do
    setup [:user_fixture_context]

    setup do
      priv_key_str = "-----BEGIN EC PRIVATE KEY-----\nMHcCAQEEIPppi4/bQXR9zNPlnGqLe/hgR3fIbX9royoFH0XLPW8/oAoGCCqGSM49\nAwEHoUQDQgAE6VQ60hlnsXZsfvxyHIOke9HjEDjJ4G6XK3WwlZfEMvQItnSUg2Ib\nAJjcTEugVGRESviKOSuwJxtN8nBTpzotDQ==\n-----END EC PRIVATE KEY-----\n"
      pub_key_str = "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBOlUOtIZZ7F2bH78chyDpHvR4xA4yeBulyt1sJWXxDL0CLZ0lINiGwCY3ExLoFRkREr4ijkrsCcbTfJwU6c6LQ0="
      pub_key_bin = {{{:ECPoint,
        <<4, 233, 84, 58, 210, 25, 103, 177, 118, 108, 126, 252, 114, 28, 131, 164,
        123, 209, 227, 16, 56, 201, 224, 110, 151, 43, 117, 176, 149, 151, 196,
        50, 244, 8, 182, 116, 148, 131, 98, 27, 0, 152, 220, 76, 75, 160, 84, 100,
        68, 74, 248, 138, 57, 43, 176, 39, 27, 77, 242, 112, 83, 167, 58, 45,
        13>>}, {:namedCurve, {1, 2, 840, 10045, 3, 1, 7}}}, []}

      {:ok, pub_key_str: pub_key_str, pub_key_bin: pub_key_bin, priv_key_str: priv_key_str}
    end

    test "a random user shouldn't get access", %{conf: conf, pub_key_str: pub_key_str} do
      [pub_key_bin] = :public_key.ssh_decode(pub_key_str, :auth_keys)
      refute SshKeyAuthentication.is_auth_key(pub_key_bin, 'git', conf)
    end

    test "checks if the user key is authorized", %{conf: conf, user: user, pub_key_str: pub_key_str, pub_key_bin: pub_key_bin} do
      {:ok, _} = Accounts.create_key(user, %{title: "My Key",  key: pub_key_str, type: :ssh})
      assert SshKeyAuthentication.is_auth_key(pub_key_bin, 'git', conf)
    end

    test "only allow user git to authenticate", %{conf: conf, pub_key_str: pub_key_str, user: user} do
      {:ok, _} = Accounts.create_key(user, %{title: "My Key",  key: pub_key_str, type: :ssh})
      [pub_key_bin] = :public_key.ssh_decode(pub_key_str, :auth_keys)
      refute SshKeyAuthentication.is_auth_key(pub_key_bin, 'boo', conf)
    end

    test "authorized user using RSA key", %{conf: conf, user: user} do
      rsa_pub_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC7LFnPpu0rnEXz0vHVP0amm5IN8ySRL0ULMXACVm5Upnaps8xvLof2evahxMgrZmB4He+QWVUXnm0ODeboBLy/gZhVStRyeRwd98wpSl9Srbb5DiCrKcHIysnrAUNh0YxXvqri33dWhkY6gTzfLDbwcg5lTS9udofK4v5Ler94MJ58WW4Q0RKV+/wsIh8ia4TbNBOqSv+fOaGNzcq3hIjUwvNEjwLS6oMkXA0hEFwJ1WF4SUDAK+0QrG8IUT2RzYUVby7HaQFyLORpG+NCQTnx4++/pu1N7Kf7uBmk33Y3sbK7VOvv/OSRXA5w4XhGLqK9hWoRyIZKOY4lAqZoKfW/"
      [{key, _}] =  :public_key.ssh_decode(rsa_pub_key, :auth_keys)
      refute SshKeyAuthentication.is_auth_key(key, 'git', conf)
      {:ok, _} = Accounts.create_key(user, %{title: "My Key",  key: rsa_pub_key, type: :ssh})
      assert SshKeyAuthentication.is_auth_key(key, 'git', conf)
    end
  end
end
