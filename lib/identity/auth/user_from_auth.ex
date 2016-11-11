defmodule Identity.UserFromAuth do
  @moduledoc """
  Provides a valid User from authentication data.
  """

  alias Identity.{User, Authorization}

  @random_password_length 64

  def get(%{email: email, password: password}, repo) do
    case repo.get_by(User, email: email) do
      %User{} = user ->
        if Comeonin.Bcrypt.checkpw(password, user.encrypted_password) do
          {:ok, user}
        else
          {:error, :not_found}
        end
      nil -> {:error, :not_found}
    end
  end
  def get(%{provider: :github} = auth, repo) do
    case repo.get_by(Authorization, uid: auth.uid) do
      %Authorization{} = authorization ->
        authorization = if authorization.expires_at && authorization.expires_at < Guardian.Utils.timestamp do
          replace_authorization(authorization, auth, repo)
        else
          authorization
        end

        {:ok, user_from_authorization(authorization, repo)}
      nil -> new_user(auth, repo)
    end
  end

  defp replace_authorization(authorization, auth, repo) do
    case repo.transaction(fn ->
      user = user_from_authorization(authorization, repo)
      repo.delete!(authorization)

      user
      |> new_authorization(auth)
      |> repo.insert!
      |> repo.preload(:user)
    end) do
      {:ok, authorization} -> authorization
      {:error, _reason} -> authorization
    end
  end

  defp user_from_authorization(authorization, repo) do
    repo.preload(authorization, :user).user
  end

  defp new_user(%{provider: :github} = auth, repo) do
    password = random_password
    user_params = %{
      name: auth.info.name,
      email: auth.info.email,
      password: password,
      password_confirmation: password
    }
    changeset = User.changeset_with_password(%User{}, user_params)

    case repo.insert(changeset) do
      {:ok, user} ->
        case user |> new_authorization(auth) |> repo.insert do
          {:ok, _auth}      -> {:ok, user}
          {:error, _reason} -> {:error, :not_found}
        end
      true -> {:error, :not_found}
    end
  end

  defp random_password do
    @random_password_length
    |> :crypto.strong_rand_bytes
    |> Base.encode64
    |> binary_part(0, @random_password_length)
  end

  defp new_authorization(user, auth) do
    Authorization.changeset(%Authorization{}, %{
      provider: to_string(auth.provider),
      uid: auth.uid,
      token: auth.credentials.token,
      refresh_token: auth.credentials.refresh_token,
      expires_at: auth.credentials.expires_at,
      user_id: user.id
    })
  end
end
