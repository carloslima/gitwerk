defmodule GitWerkWeb.UserView do
  use GitWerkWeb, :view
  alias GitWerkWeb.UserView
  use JaSerializer.PhoenixView

  attributes [:email, :username]
end
