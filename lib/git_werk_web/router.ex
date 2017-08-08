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
    plug :accepts, ["json"]
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
    resources "/sessions", SessionController, except: [:new, :delete]
    resources "/users", UserController, param: "slug", only: [:create, :show] do
      resources "/repositories", RepositoryController, param: "slug", only: [:show]
    end
  end
  scope "/api/v1", GitWerkWeb do
    pipe_through [:api, :api_authenticated]
    resources "/repositories", RepositoryController, except: [:new]
  end

  scope "/", GitWerkWeb do
    pipe_through :browser # Use the default browser stack

    get "/*path", PageController, :index
  end
end

