defmodule Gitwerk.Web.Router do
  use Gitwerk.Web, :router

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
    plug Guardian.Plug.EnsureAuthenticated, handler: Gitwerk.Web.AuthErrorHandler
    #plug DeveloperCloud.CurrentUserPlug
  end

  scope "/api/v1", Gitwerk.Web do
    pipe_through [:api, :api_optional_auth]
    resources "/sessions", SessionController, except: [:new, :delete]
    resources "/users", UserController, param: "slug", only: [:create, :show] do
      resources "/repositories", RepositoryController, param: "slug", only: [:show]
    end
  end
  scope "/api/v1", Gitwerk.Web do
    pipe_through [:api, :api_authenticated]
    resources "/repositories", RepositoryController, except: [:new]
  end

  scope "/", Gitwerk.Web do
    pipe_through :browser # Use the default browser stack

    get "/*path", PageController, :index
  end
end
