defmodule Identity.Plug.ReturnUrl do
  import Plug.Conn

  def store_return_url(conn, _) do
    conn = fetch_session(conn)
    |> fetch_query_params

    case conn.params["return_url"] do
      nil -> conn
      return_url -> put_session(conn, :return_url, return_url)
    end
  end

  def redirect_to_return_url(conn, _) do
    conn = fetch_session(conn)
    {return_url, user} = {get_session(conn, :return_url), Guardian.Plug.current_resource(conn)}

    handle_redirect(conn, {return_url, user})
  end

  defp handle_redirect(conn, {nil, _user}), do: conn
  defp handle_redirect(conn, {_return_url, nil}), do: conn
  defp handle_redirect(conn, {return_url, %Identity.User{}}) do
    put_session(conn, :return_url, return_url)
    |> Phoenix.Controller.redirect(external: return_url)
    |> halt
  end
end
