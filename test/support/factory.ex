defmodule Identity.Factory do
  use ExMachina.Ecto, repo: Identity.Repo

  alias Identity.{User, Authorization}

  def user_factory do
    %User{
      name: "Bob Belcher",
      email: "email@example.com",
      password: "secret",
      password_confirmation: "secret",
      encrypted_password: Comeonin.Bcrypt.hashpwsalt("secret")
    }
  end

  def authorization_factory do
    %Authorization{
      provider: to_string(:github),
      uid: "email@example.com",
      token: "token",
      refresh_token: "refresh_token",
      expires_at: Guardian.Utils.timestamp + 1000,
      user: build(:user)
    }
  end
end
