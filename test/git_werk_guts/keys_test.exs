defmodule GitWerkGuts.KeysTest do
  use ExUnit.Case
  import GitWerk.TestHelpers
  alias GitWerkGuts.SshAuthorizedKeys, as: Keys

  @valid_key "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAklOUpkDHrfHY17SbrmTIpNLTGK9Tjom/BWDSUGPl+nafzlHDTYW7hdI4yZ5ew18JH4JW9jbhUFrviQzM7xlELEVf4h9lFX5QVkbPppSwg0cda3Pbv7kOdJ/MTyBlWXFCR+HAo3FXRitBqxiX1nKhXpHAZsMciLq8V6RjsNAQwdsdMFvSlVK/7XAt3FaoJoAsncM1Q9x5+3V0Ww68/eIFmb1zuUFljQJKprrX88XypNDvjYNby6vw/Pb0rwert/EnmZ+AW4OZPnTPI89ZPmVMLuayrD2cE86Z/il8b+gw3r3+1nKatmIkjn2so1d01QraTlMqVSsbxNrRFi9wrf+M7Q=="

  describe "authorized_keys2 file -> " do
    test "creates it if it doesn't exists" do
      file = fixture(:temp_file) <> "/.ssh/authorized_keys2"
      :ok = Keys.create(file)
      assert File.exists?(file)
      :ok = Keys.create(file)
      assert File.lstat(file)
    end

    test "makes sure has the correct file mode" do
      file = fixture(:temp_file) <> "/.ssh/authorized_keys2"
      :ok = Keys.create(file)
      {:ok, stat} = File.lstat(file)
      assert stat.mode == 33152
    end
  end
  describe "keys server" do
    setup [:start_server]

    def start_server(_) do
      file = fixture(:temp_file) <> "/.ssh/authorized_keys2"
      {:ok, key_srv} = Keys.start_link(authorized_keys_file: file)
      {:ok, key_server: key_srv, authorized_keys: file}
    end

    test "adds a key to the file", %{key_server: key_srv, authorized_keys: file} do
      :ok = Keys.add(key_srv, UUID.uuid4, @valid_key)
      :sys.get_state(key_srv)
      assert File.exists?(file)
      assert File.read!(file) != ""
    end

    test "list a keys" , %{key_server: key_srv}do
      key_id = UUID.uuid4
      :ok = Keys.add(key_srv, key_id, @valid_key)
      :sys.get_state(key_srv)
      assert Keys.has?(key_srv, key_id: key_id)
    end

    test "doesn't add one key twice", %{key_server: key_srv}do
      key_id = UUID.uuid4
      Keys.add(key_srv, key_id, @valid_key)
      :sys.get_state(key_srv)
      Keys.add(key_srv, key_id, @valid_key)
      :sys.get_state(key_srv)
      keys_count = Keys.count(key_srv)
      assert keys_count == 1
    end

    @tag :skip
    test "removes a key", %{key_server: key_srv} do
      key_id1 = UUID.uuid4
      key_id2 = UUID.uuid4
      Keys.add(key_srv, key_id1, @valid_key)
      Keys.add(key_srv, key_id2, @valid_key)
      Keys.remove(key_srv, key_id: key_id1)
      assert Keys.has?(key_srv, key_id: key_id2)
    end
  end
end
