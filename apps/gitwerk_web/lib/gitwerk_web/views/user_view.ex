defmodule Gitwerk.Web.UserView do
  use Gitwerk.Web, :view
  alias Gitwerk.Web.UserView

  def render("show.json", %{user: user}) do
    render_one(user, UserView, "user.json")
  end

  def render("user.json", %{user: %{jwt_token: jwt_token} = user}) when not is_nil(jwt_token) do
    %{id: user.id,
      username: user.username,
      email: user.email,
      jwt_token: user.jwt_token}
  end

  def render("user.json", %{user: user}) do
    %{id: user.id,
      username: user.username,
      email: user.email
    }
  end
end

