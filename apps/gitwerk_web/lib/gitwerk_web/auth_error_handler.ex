defmodule Gitwerk.Web.AuthErrorHandler do
  import Phoenix.Controller
  import Plug.Conn

  def unauthenticated(conn, _params) do
    error = %{"authentication" => "field required in header"}
    conn
    |> put_status(:unauthorized)
    |> render(Gitwerk.Web.ErrorView, "error.json", error: error)
  end
end
#
