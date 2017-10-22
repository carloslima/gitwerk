defmodule GitWerkWeb.LoadRepositoryPlugTest do
  use GitWerkWeb.ConnCase

  alias GitWerkWeb.LoadRepositoryPlug

  test "loads a private repo with public access", %{conn: conn} do
    user = user_fixture()
    repository = repository_fixture(user_id: user.id)
    conn =
      conn
      |> Map.put(:params, %{repository_slug: repository.name, user_slug: user.username})
      |> Plug.Conn.fetch_query_params([])
      |> LoadRepositoryPlug.call(%{})

    refute conn.assigns.repository
  end
end
