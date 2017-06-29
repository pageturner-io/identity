defmodule Identity.Router do
  use Identity.Web, :router
  require Ueberauth
  import Identity.Plug.ReturnUrl

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

  pipeline :return_url do
    plug :store_return_url
    plug :redirect_to_return_url
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Identity do
    pipe_through [:browser, :browser_auth, :return_url]

    get "/", PageController, :index
    get "/register", UserController, :new
    post "/register", UserController, :create
    get "/login", AuthController, :login
    post "/login", AuthController, :login
    delete "/logout", AuthController, :logout
  end

  scope "/auth", Identity do
    pipe_through [:browser, :browser_auth, :return_url]

    get "/:provider", AuthController, :request
    get "/:provider/callback", AuthController, :callback
    post "/:provider/callback", AuthController, :callback
  end

  # Other scopes may use custom stacks.
  # scope "/api", Identity do
  #   pipe_through :api
  # end
end
