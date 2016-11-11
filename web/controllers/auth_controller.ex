defmodule Identity.AuthController do
  use Identity.Web, :controller
  use Guardian.Phoenix.Controller

  alias Identity.User
  alias Identity.Repo
  alias Identity.UserFromAuth

  plug Ueberauth

  def login(conn, _params, current_user, _claims) when not is_nil(current_user) do
    conn |> redirect(to: page_path(conn, :index))
  end
  def login(conn, %{"user" => user_params}, current_user, _claims) when is_nil(current_user) do
    params = %{
      email: user_params["email"],
      password: user_params["password"]
    }
    case UserFromAuth.get(params, Repo) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "Signed in as #{user.name}")
        |> Guardian.Plug.sign_in(user, :access, perms: %{default: Guardian.Permissions.max})
        |> redirect(to: page_path(conn, :index))

      {:error, :not_found} ->
        conn
        |> put_flash(:error, "Username or password are incorrect.")
        |> render(changeset: User.changeset(%User{}))
    end
  end
  def login(conn, _params, _current_user, _claims), do: render(conn, changeset: User.changeset(%User{}))

  def request(conn, _params, _current_user, _claims), do: conn

  def logout(conn, _params, current_user, _claims) when is_nil(current_user) do
    conn |> redirect(to: page_path(conn, :index))
  end
  def logout(conn, _params, current_user, _claims) when not is_nil(current_user) do
    conn
    |> Guardian.Plug.sign_out
    |> put_flash(:info, "Signed out")
    |> redirect(to: page_path(conn, :index))
  end

  def callback(%Plug.Conn{assigns: %{ueberauth_auth: auth}} = conn, _params, _current_user, _claims) do
    case UserFromAuth.get(auth, Repo) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "Signed in as #{user.name}")
        |> Guardian.Plug.sign_in(user, :access, perms: %{default: Guardian.Permissions.max})
        |> redirect(to: page_path(conn, :index))

      {:error, :not_found} ->
        conn
        |> put_flash(:error, "Username or password are incorrect.")
        |> render(changeset: User.changeset(%User{}))
    end
  end

end
