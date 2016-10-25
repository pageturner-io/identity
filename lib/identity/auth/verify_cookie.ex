defmodule Identity.Plug.VerifyCookie do
  @moduledoc """
  Use this plug to verify a token contained in a cookie.
  ## Example
      plug Identity.Plug.VerifySession
  You can also specify a location to look for the token
  ## Example
      plug Identity.Plug.VerifySession, key: :secret
  Verifying the session will update the claims on the request,
  available with Guardian.Plug.claims/1
  In the case of an error, the claims will be set to { :error, reason }
  """
  import Guardian.Keys

  @doc false
  def init(opts \\ %{}), do: Enum.into(opts, %{})

  @doc false
  def call(conn, opts) do
    key = Map.get(opts, :key, :default)

    case Guardian.Plug.claims(conn, key) do
      {:ok, _} -> conn
      {:error, _} ->
        jwt = conn.cookies["pageturner_identity"]

        if jwt do
          case Guardian.decode_and_verify(jwt, %{}) do
            {:ok, claims} ->
              conn
              |> Guardian.Plug.set_claims({:ok, claims}, key)
              |> Guardian.Plug.set_current_token(jwt, key)
            {:error, reason} ->
              conn
              |> Plug.Conn.delete_session(base_key(key))
              |> Guardian.Plug.set_claims({:error, reason}, key)
          end
        else
          conn
        end
    end
  end
end
