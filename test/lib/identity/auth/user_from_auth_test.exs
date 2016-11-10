defmodule Identity.UserFromAuthTest do

  use Identity.ConnCase

  alias Identity.UserFromAuth
  alias Identity.Repo
  alias Identity.User
  alias Ueberauth.Auth
  alias Ueberauth.Auth.Credentials
  alias Ueberauth.Auth.Info

  import Identity.Factory

  @name "Boaty McBoatface"
  @email "boaty_mcboatface@gmail.com"
  @provider :github
  @token "the-token"
  @refresh_token "refresh-token"

  setup do
    auth = %Auth{
      uid: @email,
      provider: @provider,
      info: %Info{
        name: @name,
        email: @email,
      },
      credentials: %Credentials{
        token: @token,
        refresh_token: "refresh-token",
        expires_at: Guardian.Utils.timestamp + 1000,
      }
    }

    {:ok, %{
        user: insert(:user),
        auth: auth
      }
    }
  end

  def user_count, do: Repo.one(from u in User, select: count(u.id))

  test "with an existing user with valid email/password logs returns that user", %{user: persisted_user} do
    {:ok, user} = UserFromAuth.get(%{
      email: persisted_user.email,
      password: persisted_user.password,
    }, Repo)

    assert user != nil
    assert user.id == persisted_user.id
  end

  test "with invalid email/password logs returns a not found error" do
    result = UserFromAuth.get(%{
      email: "foo@foo.com",
      password: "bar"
    }, Repo)

    assert result == {:error, :not_found}
  end

  test "with a Github authorization for an existing user returns that user", %{user: persisted_user} do
    auth = %Auth{
      uid: persisted_user.email,
      provider: @provider,
      info: %Info{
        name: persisted_user.name,
        email: persisted_user.email,
      },
      credentials: %Credentials{
        token: @token,
        refresh_token: "refresh-token",
        expires_at: Guardian.Utils.timestamp + 1000,
      }
    }

    before_users = user_count
    {:ok, user} = UserFromAuth.get(auth, Repo)
    after_users = user_count

    assert after_users == before_users

    assert user.id == persisted_user.id
  end

  test "with a Github authorization for a non-existing user creates that user", %{auth: auth} do
    before_users = user_count
    {:ok, user} = UserFromAuth.get(auth, Repo)
    after_users = user_count

    assert after_users == (before_users + 1)

    assert user.email == @email
  end

end