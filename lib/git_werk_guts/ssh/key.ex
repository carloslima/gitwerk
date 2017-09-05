defmodule GitWerkGuts.SshKey do

  @erl_ssh_decode ["ssh-rsa", "ssh-dss"]
  @ecdsa_key_types ["ecdsa-sha2-nistp256", "ecdsa-sha2-nistp521", "ecdsa-sha2-nistp384"]

  def validate_pub_key(<<key_type::binary-size(7), _::binary >> = public_key) when key_type in @erl_ssh_decode do
    try do
      :public_key.ssh_decode(public_key, :public_key)
      :ok
    rescue
      err ->
        {:error, err}
    end
  end

  def validate_pub_key(<<key_type::binary-size(11), key::binary>>) when key_type == "ssh-ed25519" do
    case Base.decode64(String.trim(key)) do
      {:ok, bin_key} when byte_size(bin_key) == 51 -> :ok
      err -> {:error, err}
    end
  end

  def validate_pub_key(<<key_type::binary-size(19), key::binary>>) when key_type in @ecdsa_key_types do
    expected_size = %{"ecdsa-sha2-nistp256" => 104, "ecdsa-sha2-nistp521" => 172, "ecdsa-sha2-nistp384" => 136}
    key_size = expected_size[key_type]
    case Base.decode64(String.trim(key)) do
      {:ok, bin_key} when byte_size(bin_key) == key_size -> :ok
      err -> {:error, err}
    end
  end
  def validate_pub_key(_) do
    {:error, :unknown_key}
  end
end
