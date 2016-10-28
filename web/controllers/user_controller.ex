defmodule Identity.UserController do
  use Identity.Web, :controller
  use Guardian.Phoenix.Controller

  alias Identity.User
  alias Identity.Repo

  def new(conn, _params, current_user, _claims) when not is_nil(current_user) do
    redirect(conn, to: page_path(conn, :index))
  end
  def new(conn, _params, _current_user, _claims) do
    changeset = User.changeset(%User{})
    render conn, changeset: changeset
  end

  def create(conn, _params, current_user, _claims) when not is_nil(current_user) do
    redirect(conn, to: page_path(conn, :index))
  end
  def create(conn, %{"user" => user_params}, _current_user, _claims) do
    changeset = User.changeset_with_password(%User{}, user_params)

    case Repo.insert(changeset) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "Signed in as #{user.name}")
        |> Guardian.Plug.sign_in(user, :access, perms: %{default: Guardian.Permissions.max})
        |> redirect(to: page_path(conn, :index))

      {:error, changeset} ->
        conn
        |> render("new.html", changeset: changeset)
    end
  end
end
