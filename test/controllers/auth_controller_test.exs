defmodule Identity.AuthControllerTest do
  use Identity.ConnCase

  import Identity.Factory

  @hivent Application.get_env(:identity, :hivent)

  defp cookie_config do
    Application.get_env(:identity, Identity.Auth)
    |> Keyword.fetch!(:cookie)
  end

  setup do
    @hivent.Emitter.Cache.clear

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

  test "POST /login with valid data sets an SSO cookie with the user's token", %{conn: conn, user: user} do
    conn = post conn, "/login", %{
      user: %{
        email: user.email,
        password: user.password,
      }
    }

    cookie_name = cookie_config()[:name]

    assert conn.resp_cookies[cookie_name][:value] == Guardian.Plug.current_token(conn)
    assert conn.resp_cookies[cookie_name][:max_age] == cookie_config()[:max_age]
    assert conn.resp_cookies[cookie_name][:domain] == cookie_config()[:domain]
  end

  test "POST /login with valid data emits an event with the user's token", %{conn: conn, user: user} do
    conn = post conn, "/login", %{
      user: %{
        email: user.email,
        password: user.password,
      }
    }

    event = @hivent.Emitter.Cache.last

    assert event.meta.name == "identity:user:signed_in"
    assert event.payload.user.id == user.id
    assert event.payload.user.authentication_token == Guardian.Plug.current_token(conn)
    assert event.payload.user.email == user.email
    assert event.payload.user.name == user.name
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
    conn = guardian_login(conn, user) |> delete("/logout")

    cookie_name = cookie_config()[:name]

    assert Guardian.Plug.current_resource(conn) == nil
    assert redirected_to(conn) =~ page_path(conn, :index)
    assert conn.cookies[cookie_name] == nil
  end

  test "DELETE /logout with a logged in user emits an event with the user's id", %{conn: conn, user: user} do
    guardian_login(conn, user) |> delete("/logout")

    event = @hivent.Emitter.Cache.last

    assert event.meta.name == "identity:user:signed_out"
    assert event.payload.user.id == user.id
  end

end
