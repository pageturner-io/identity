defmodule Identity.UserControllerTest do
  use Identity.ConnCase

  alias Identity.Repo
  alias Identity.User

  import Identity.Factory
  import Ecto.Query

  setup do
    {:ok, %{
        user: insert(:user)
      }
    }
  end

  test "GET /register renders signup page", %{conn: conn} do
    conn = get conn, "/register"
    assert html_response(conn, 200) =~ "Register"
  end

  test "GET /register with a logged in user redirects to index", %{conn: conn, user: user} do
    conn = guardian_login(conn, user)
    |> get("/register")

    assert redirected_to(conn) =~ page_path(conn, :index)
  end

  test "POST /register with valid data creates a new user", %{conn: conn} do
    post conn, "/register", %{
      user: %{
        name: "foobar",
        email: "foo@bar.com",
        password: "secret",
        password_confirmation: "secret"
      }
    }

    [user | _] = User |> where(email: "foo@bar.com") |> limit(1) |> Repo.all

    assert user
  end

  test "POST /register with a user whow already exists shows errors", %{conn: conn} do
    user = insert(:user)

    conn = post conn, "/register", %{
      user: %{
        name: user.name,
        email: user.email,
        password: "secret",
        password_confirmation: "secret"
      }
    }

    assert html_response(conn, 200) =~ "Email has already been taken"
  end

  test "POST /register with invalid data renders errors", %{conn: conn} do
    conn = post conn, "/register", %{user: %{email: "invalid"}}

    assert html_response(conn, 200) =~ "Email has invalid format"
  end

  test "POST /register with a logged in user redirects to index", %{conn: conn, user: user} do
    conn = guardian_login(conn, user)
    |> post("/register")

    assert redirected_to(conn) =~ page_path(conn, :index)
  end
end
