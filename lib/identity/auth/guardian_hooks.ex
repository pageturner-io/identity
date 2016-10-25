defmodule Identity.Auth.GuardianHooks do
  use Guardian.Hooks

  def after_sign_in(conn, location) do
    token = Guardian.Plug.current_token(conn, location)

    conn
    |> Plug.Conn.put_resp_cookie(name, token, [
      domain: domain,
      max_age: max_age
    ])
  end

  def before_sign_out(conn, _location) do
    conn
    |> Plug.Conn.delete_resp_cookie(name, [
      domain: domain,
      max_age: max_age
    ])
  end

  defp cookie_config do
    Application.get_env(:identity, Identity.Auth)
    |> Dict.get(:cookie)
  end

  defp domain do
    cookie_config[:domain]
  end

  defp max_age do
    cookie_config[:max_age]
  end

  defp name do
    cookie_config[:name]
  end
end
