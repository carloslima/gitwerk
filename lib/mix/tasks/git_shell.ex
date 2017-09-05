defmodule Mix.Tasks.GitShell do
  def run(args) do
    args
    |> OptionParser.parse
    |> IO.inspect
    node_name = Base.decode16(:crypto.strong_rand_bytes(9))
    :net_kernel.start([node_name, :shortnames])
    {:ok, hostname} = :inet.gethostname
    node = :"gitwerk_srv@#{hostname}"
    :rpc.call(node, :lists, :sort, [[1, 2, 4, -1, 8, 3]])
    |> IO.inspect
  end
end
