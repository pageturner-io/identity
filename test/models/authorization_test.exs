defmodule Identity.AuthorizationTest do
  use Identity.ModelCase

  alias Identity.Authorization
  alias Identity.Repo

  @valid_attrs %{expires_at: 42, provider: "some content", user_id: 1, refresh_token: "some content", token: "some content", uid: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Authorization.changeset(%Authorization{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Authorization.changeset(%Authorization{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "inserting a changeset with an invalid user_id" do
    {:error, changeset} = Authorization.changeset(%Authorization{}, %{@valid_attrs | user_id: 404})
    |> Repo.insert

    refute changeset.valid?
    assert {:user_id, {"does not exist", []}} in changeset.errors
  end
end
