defmodule Identity.Plug.ReturnUrlTest do
  use Identity.ConnCase, async: true
  import Plug.Conn
  import Identity.Factory

  @session Plug.Session.init(
    store: :cookie,
    key: "_my_app_session",
    encryption_salt: "cookie store encryption salt",
    signing_salt: "cookie store signing salt",
    key_length: 64,
    log: :debug
  )

  defp put_secret_key_base(conn, _) do
    put_in(conn.secret_key_base, random_string(64))
  end

  defp random_string(length) do
    :crypto.strong_rand_bytes(length) |> Base.url_encode64 |> binary_part(0, length)
  end

  setup do
    [user: insert(:user)]
  end

  describe ".store_return_url/2" do

    test "stores \"return_url\" querystring parameter in the session" do
      return_url = "https://example.com"

      conn = build_conn(:get, "/foo?return_url=#{return_url}")
      |> Plug.Session.call(@session)
      |> Identity.Plug.ReturnUrl.store_return_url(%{})

      assert get_session(conn, :return_url) == return_url
    end


    test "does not store \"return_url\" in the session if no querystring parameter is given" do
      conn = build_conn(:get, "/foo?bar=baz")
      |> Plug.Session.call(@session)
      |> Identity.Plug.ReturnUrl.store_return_url(%{})

      refute get_session(conn, :return_url)
    end
  end

  describe "redirect_to_return_url/2" do
    test "does not redirect if there is no return_url", %{user: user} do
      path = "/foo"

      conn = build_conn(:get, path)
      |> Plug.Session.call(@session)
      |> fetch_session
      |> Guardian.Plug.sign_in(user, :token, [])
      |> put_session(:return_url, nil)
      |> Identity.Plug.ReturnUrl.redirect_to_return_url(%{})

      assert conn.request_path == path
    end

    test "does not redirect if there is no user" do
      path = "/foo"

      conn = build_conn(:get, path)
      |> Plug.Session.call(@session)
      |> fetch_session
      |> put_session(:return_url, "https://example.com")
      |> Identity.Plug.ReturnUrl.redirect_to_return_url(%{})

      assert conn.request_path == path
    end

    test "redirects if there is a return_url and a user", %{user: user} do
      return_url = "https://example.com"

      conn = build_conn(:get, "/foo")
      |> Plug.Session.call(@session)
      |> fetch_session
      |> Guardian.Plug.sign_in(user, :token, [])
      |> put_session(:return_url, return_url)
      |> put_secret_key_base(nil)
      |> Identity.Plug.ReturnUrl.redirect_to_return_url(%{})

      assert redirected_to(conn) =~ return_url
    end
  end
end
