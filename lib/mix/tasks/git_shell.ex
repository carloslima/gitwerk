defmodule Mix.Tasks.GitShell do
  def run(args) do
    {[key: key, command: command], _, _} = OptionParser.parse(args)
    node_name = Base.encode16(:crypto.strong_rand_bytes(9))
    {:ok, _} = :net_kernel.start([String.to_atom(node_name), :shortnames])
    {:ok, hostname} = :inet.gethostname
    main_node = :"gitwerk_srv@#{hostname}"
    resp = :rpc.call(main_node, :"Elixir.GitWerkGuts.Ssh", :get_git_command, [command, key])
    if resp == "" do
      IO.puts ""
    else
      IO.puts resp
    end
    System.halt(0)
  end
end
