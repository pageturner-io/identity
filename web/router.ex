defmodule Identity.Router do
  use Identity.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :browser_auth do
    plug Identity.Plug.VerifyCookie
    plug Guardian.Plug.LoadResource
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Identity do
    pipe_through [:browser, :browser_auth]

    get "/", PageController, :index
    get "/register", UserController, :new
    post "/register", UserController, :create
    get "/login", AuthController, :login
    post "/login", AuthController, :login
    delete "/logout", AuthController, :logout
  end

  # Other scopes may use custom stacks.
  # scope "/api", Identity do
  #   pipe_through :api
  # end
end
