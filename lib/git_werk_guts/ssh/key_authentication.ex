defmodule GitWerkGuts.SshKeyAuthentication do
  @behaviour :ssh_server_key_api

  require Record

  Record.defrecord :RSAPublicKey,  Record.extract(:RSAPublicKey, from_lib: "public_key/include/public_key.hrl")
  Record.defrecord :RSAPrivateKey, Record.extract(:RSAPrivateKey, from_lib: "public_key/include/public_key.hrl")
  Record.defrecord :DSAPrivateKey, Record.extract(:DSAPrivateKey, from_lib: "public_key/include/public_key.hrl")
  Record.defrecord :'Dss-Parms',   Record.extract(:'Dss-Parms', from_lib: "public_key/include/public_key.hrl")


  @type public_key :: :public_key.public_key()
  @type private_key :: map | map | term
  @type public_key_algorithm :: :'ssh-rsa'| :'ssh-dss' | atom
  @type user :: charlist()
  @type daemon_options :: Keyword.t

  @doc """
  Fetches the private key of the host.
  """
  @spec host_key(public_key_algorithm, daemon_options) ::
    {:ok, private_key} | {:error, any}
  def host_key(algorithm, daemon_options) do
    with base_name <- file_base_name(algorithm),
         file_path <- file_full_path(base_name, daemon_options),
         {:ok, bin} <- File.read(file_path),
         {:ok, key} <- decode_ssh_file(bin, nil) do
           {:ok, key}
    else
      {:error, :enoent} -> {:error, :no_host_key_found}
      {:error, :no_pass_phrase_provided} -> {:error, :failed_to_load_host_key}
      _ -> {:error, :no_idea}
    end
  end

  defp file_base_name(:"ssh-rsa"), do: "ssh_host_rsa_key"
  defp file_base_name(:"rsa-sha2-256"), do: "ssh_host_rsa_key"
  defp file_base_name(:"rsa-sha2-384"), do: "ssh_host_rsa_key"
  defp file_base_name(:"rsa-sha2-512"), do: "ssh_host_rsa_key"
  defp file_base_name(:"ssh-dss"), do: "ssh_host_dsa_key"
  defp file_base_name(:"ecdsa-sha2-nistp256"), do: "ssh_host_ecdsa_key"
  defp file_base_name(:"ecdsa-sha2-nistp384"), do: "ssh_host_ecdsa_key"
  defp file_base_name(:"ecdsa-sha2-nistp521"), do: "ssh_host_ecdsa_key"
  defp file_base_name(_), do: "ssh_host_key"

  defp file_full_path(name, opts) do
    opts
    |> ssh_dir
    |> Path.join(name)
  end

  defp ssh_dir(opts) do
    case Keyword.fetch(opts, :system_dir) do
      {:ok, dir} -> dir
      :error     -> "/etc/ssh"
    end
  end

  defp decode_ssh_file(pem, password) do
    case :public_key.pem_decode(pem) do
      [{_, _, :not_encrypted} = entry] ->
        {:ok, :public_key.pem_entry_decode(entry)}
      [entry] when password != :ignore ->
        {:ok, :public_key.pem_entry_decode(entry, password)}
      _ ->
        {:error, :no_pass_phrase_provided}
    end
  end
end
