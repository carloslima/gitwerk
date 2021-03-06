defmodule GitWerkWeb.Router do
  use GitWerkWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json", "json-api"]
  end


  pipeline :api_optional_auth do
    plug Guardian.Plug.VerifyHeader, realm: "Bearer"
    plug Guardian.Plug.LoadResource
  end

  pipeline :api_authenticated do
    plug Guardian.Plug.VerifyHeader, realm: "Bearer"
    plug Guardian.Plug.LoadResource
    plug Guardian.Plug.EnsureAuthenticated, handler: GitWerkWeb.AuthErrorHandler
  end

  scope "/api/v1", GitWerkWeb do
    pipe_through [:api, :api_optional_auth]
    resources "/repositories", RepositoryController, only: [:show] do
      get "/code/file-list/:tree_id/*path", CodeController, :file_list
      get "/trees/:tree_id/", TreeController, :show
      get "/trees/:tree_id/entries/*path", CodeController, :entries
    end
    resources "/sessions", SessionController, only: [:create]
    resources "/users", UserController, only: [:create, :show]
  end

  scope "/api/v1", GitWerkWeb do
    pipe_through [:api, :api_authenticated]
    resources "/repositories", RepositoryController, except: [:new]
    get "/sessions/current", UserController, :current
    scope "/users/:user_slug", as: :user_setting do
      resources "/keys/", UserKeyController, as: :key, only: [:create, :index]
    end
  end

  scope "/", GitWerkWeb do
    pipe_through :browser # Use the default browser stack

    get "/*path", PageController, :index
  end
end
