defmodule Identity.UserFromAuth do

  alias Identity.User

  def get(%{email: email, password: password}, repo) do
    case repo.get_by(User, email: email) do
      %User{} = user ->
        cond do
          Comeonin.Bcrypt.checkpw(password, user.encrypted_password) -> {:ok, user}
          true -> {:error, :not_found}
        end
      nil -> {:error, :not_found}
    end
  end
  def get(%{provider: :github} = auth, repo) do
    case repo.get_by(User, email: auth.uid) do
      %User{} = user -> {:ok, user}
      nil            -> new_user(auth, repo)
    end
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
      {:ok, user} -> {:ok, user}
      true        -> {:error, :not_found}
    end
  end

  defp random_password do
    :crypto.strong_rand_bytes(64) |> Base.encode64 |> binary_part(0, 64)
  end

end