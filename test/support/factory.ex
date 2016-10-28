defmodule Identity.Factory do
  use ExMachina.Ecto, repo: Identity.Repo

  alias Identity.User

  def user_factory do
    %User{
      name: "Bob Belcher",
      email: sequence(:email, &"email-#{&1}@example.com"),
      password: "secret",
      password_confirmation: "secret",
      encrypted_password: Comeonin.Bcrypt.hashpwsalt("secret")
    }
  end
end
