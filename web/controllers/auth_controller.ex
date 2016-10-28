defmodule Identity.AuthController do
  use Identity.Web, :controller
  use Guardian.Phoenix.Controller

  alias Identity.User
  alias Identity.Repo

  def login(conn, _params, current_user, _claims) when not is_nil(current_user) do
    conn |> redirect(to: page_path(conn, :index))
  end
  def login(conn, %{"user" => user_params}, current_user, _claims) when is_nil(current_user) do
    case Repo.get_by(User, email: user_params["email"]) do
      %User{} = user ->
        cond do
          Comeonin.Bcrypt.checkpw(user_params["password"], user.encrypted_password) ->
            conn
            |> put_flash(:info, "Signed in as #{user.name}")
            |> Guardian.Plug.sign_in(user, :access, perms: %{default: Guardian.Permissions.max})
            |> redirect(to: page_path(conn, :index))
          true ->
            conn
              |> put_flash(:error, "Username or password are incorrect.")
              |> render
        end
      nil ->
        conn
        |> put_flash(:error, "Username or password are incorrect.")
        |> render(changeset: User.changeset(%User{}))
    end
  end
  def login(conn, _params, _current_user, _claims), do: render conn, changeset: User.changeset(%User{})

  def logout(conn, _params, current_user, _claims) when is_nil(current_user) do
    conn |> redirect(to: page_path(conn, :index))
  end
  def logout(conn, _params, current_user, _claims) when not is_nil(current_user) do
    conn
    |> Guardian.Plug.sign_out
    |> put_flash(:info, "Signed out")
    |> redirect(to: page_path(conn, :index))
  end

end
