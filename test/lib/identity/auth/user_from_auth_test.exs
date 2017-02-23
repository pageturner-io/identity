defmodule Identity.UserFromAuthTest do

  use Identity.ConnCase

  alias Identity.UserFromAuth
  alias Identity.Repo
  alias Identity.User
  alias Identity.Authorization
  alias Ueberauth.Auth
  alias Ueberauth.Auth.Credentials
  alias Ueberauth.Auth.Info

  import Identity.Factory

  setup do
    authorization = Repo.preload(insert(:authorization), :user)

    auth = %Auth{
      uid: authorization.uid,
      provider: String.to_atom(authorization.provider),
      info: %Info{
        name: authorization.user.name,
        email: authorization.user.email,
      },
      credentials: %Credentials{
        token: authorization.token,
        refresh_token: authorization.refresh_token,
        expires_at: authorization.expires_at,
      }
    }

    {:ok, %{
        user: authorization.user,
        authorization: authorization,
        auth: auth
      }
    }
  end

  def user_count, do: Repo.one(from u in User, select: count(u.id))
  def authorization_count, do: Repo.one(from a in Authorization, select: count(a.id))

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

  test "with a Github authorization for an existing user returns that user", %{user: persisted_user, auth: auth} do
    before_users = user_count()
    before_authorizations = authorization_count()
    {:ok, user} = UserFromAuth.get(auth, Repo)
    after_users = user_count()
    after_authorizations = authorization_count()

    assert after_users == before_users
    assert after_authorizations == before_authorizations
    assert user.id == persisted_user.id
  end

  test "deletes the authorization and creates a new one when it the old one is expired", %{authorization: authorization, auth: auth, user: user} do
    authorization = Ecto.Changeset.change(authorization, expires_at: Guardian.Utils.timestamp - 500)
                    |> Repo.update!

    before_users = user_count()
    before_authorizations = authorization_count()
    {:ok, user_from_auth} = UserFromAuth.get(auth, Repo)

    assert user_from_auth.id == user.id
    assert before_users == user_count()
    assert authorization_count() == before_authorizations
    auth2 = Repo.one(Ecto.assoc(user, :authorizations))
    refute auth2.id == authorization.id
  end

  test "with a Github authorization for a non-existing user creates that user" do
    auth = %Auth{
      uid: "foo@bar.com",
      provider: :github,
      info: %Info{
        name: "Foo Bar",
        email: "foo@bar.com",
      },
      credentials: %Credentials{
        token: "a_token",
        refresh_token: "a_refresh_token",
        expires_at: Guardian.Utils.timestamp + 1000,
      }
    }

    before_users = user_count()
    {:ok, user} = UserFromAuth.get(auth, Repo)
    after_users = user_count()

    assert after_users == (before_users + 1)

    assert user.email == auth.info.email
  end

  test "with a Github authorization for a non-existing user creates an authorization with that user's token" do
     auth = %Auth{
      uid: "foo@bar.com",
      provider: :github,
      info: %Info{
        name: "Foo Bar",
        email: "foo@bar.com",
      },
      credentials: %Credentials{
        token: "a_token",
        refresh_token: "a_refresh_token",
        expires_at: Guardian.Utils.timestamp + 1000,
      }
    }

    before_authorizations = authorization_count()
    {:ok, user} = UserFromAuth.get(auth, Repo)
    after_authorizations = authorization_count()

    assert after_authorizations == (before_authorizations + 1)

    authorization = Ecto.assoc(user, :authorizations) |> Repo.one

    assert authorization.token == auth.credentials.token
  end

end
