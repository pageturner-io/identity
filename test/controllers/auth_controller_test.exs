defmodule Identity.AuthControllerTest do
  use Identity.ConnCase

  import Identity.Factory

  defp cookie_config do
    Application.get_env(:identity, Identity.Auth)
    |> Dict.get(:cookie)
  end

  setup do
    {:ok, %{
        user: insert(:user)
      }
    }
  end

  test "GET /login renders login page", %{conn: conn} do
    conn = get conn, "/login"
    assert html_response(conn, 200) =~ "Login"
  end

  test "GET /login with a logged in user redirects to index", %{conn: conn, user: user} do
    conn = guardian_login(conn, user)
    |> get("/login")

    assert redirected_to(conn) =~ page_path(conn, :index)
  end

  test "POST /login with valid data logs in the user", %{conn: conn, user: user} do
    conn = post conn, "/login", %{
      user: %{
        email: user.email,
        password: user.password,
      }
    }

    assert Guardian.Plug.current_resource(conn) != nil
  end

  test "POST /login with valid sets an SSO cookie with the user's token", %{conn: conn, user: user} do
    conn = post conn, "/login", %{
      user: %{
        email: user.email,
        password: user.password,
      }
    }

    cookie_name = cookie_config[:name]

    assert conn.resp_cookies[cookie_name][:value] == Guardian.Plug.current_token(conn)
    assert conn.resp_cookies[cookie_name][:max_age] == cookie_config[:max_age]
    assert conn.resp_cookies[cookie_name][:domain] == cookie_config[:domain]
  end

  test "POST /login with valid data redirects to the index", %{conn: conn, user: user} do
    conn = post conn, "/login", %{
      user: %{
        email: user.email,
        password: user.password,
      }
    }

    assert redirected_to(conn) =~ page_path(conn, :index)
  end

  test "POST /login with invalid data shows errors", %{conn: conn} do
    conn = post conn, "/login", %{
      user: %{
        email: "doesnot@exist.com",
        password: "foobar",
      }
    }

    assert html_response(conn, 200) =~ "Login"
    assert html_response(conn, 200) =~ "Username or password are incorrect."
  end

  test "DELETE /logout with no logged in user redirects to index", %{conn: conn} do
    conn = delete(conn, "/logout")

    assert redirected_to(conn) =~ page_path(conn, :index)
  end

  test "DELETE /logout with a logged in user logs out that user", %{conn: conn, user: user} do
    conn = guardian_login(conn, user)
    |> delete("/logout")

    cookie_name = cookie_config[:name]

    assert Guardian.Plug.current_resource(conn) == nil
    assert redirected_to(conn) =~ page_path(conn, :index)
    assert conn.cookies[cookie_name] == nil
  end

end