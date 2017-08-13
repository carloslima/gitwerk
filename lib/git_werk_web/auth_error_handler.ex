defmodule GitWerkWeb.AuthErrorHandler do
  @moduledoc false
  import Phoenix.Controller
  import Plug.Conn

  def unauthenticated(conn, _params) do
    error = %{"authentication" => "field required in header"}
    conn
    |> put_status(:unauthorized)
    |> render(GitWerkWeb.ErrorView, "error.json", error: error)
  end
end
#
