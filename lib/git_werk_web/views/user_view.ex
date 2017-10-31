defmodule GitWerkWeb.UserView do
  use GitWerkWeb, :view
  use JaSerializer.PhoenixView

  attributes [:email, :username]
end
