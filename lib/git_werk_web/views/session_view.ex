defmodule GitWerkWeb.SessionView do
  use GitWerkWeb, :view

  def render("show.json", %{user: user}) do
    %{access_token: user.jwt_token}
  end
end
