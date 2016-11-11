defmodule Identity.Auth.Hooks do
  @moduledoc false

  use Guardian.Hooks

  def after_encode_and_sign(resource, type, claims, jwt) do
    GuardianDb.after_encode_and_sign(resource, type, claims, jwt)
  end

  def on_verify(claims, jwt) do
    GuardianDb.on_verify(claims, jwt)
  end

  def on_revoke(claims, jwt) do
    GuardianDb.on_revoke(claims, jwt)
  end

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

  defp config do
    Application.get_env(:identity, Identity.Auth)
  end

  defp cookie_config do
    config
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
