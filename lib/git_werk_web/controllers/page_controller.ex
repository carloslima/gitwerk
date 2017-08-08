defmodule GitWerkWeb.PageController do
  use GitWerkWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
