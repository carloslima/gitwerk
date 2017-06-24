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

  scope "/api/v1", Gitwerk.Web do
    pipe_through :api
    resources "/users", UserController, except: [:new, :edit]
    resources "/sessions", SessionController, except: [:new, :delete]
  end

  scope "/", Gitwerk.Web do
    pipe_through :browser # Use the default browser stack

    get "/*path", PageController, :index
  end
end
