defmodule Identity.UserTest do
  use Identity.ModelCase

  alias Identity.User

  @valid_attrs %{email: "foo@bar.com", name: "Jane Doe", password: "secret", password_confirmation: "secret"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = User.changeset(%User{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = User.changeset(%User{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "changeset with invalid email address" do
    changeset = User.changeset(%User{}, %{email: "invalid", name: "Jane Doe"})
    refute changeset.valid?
  end

  test "changeset_with_password with valid attributes generates an encrypted password" do
    changeset = User.changeset_with_password(%User{}, @valid_attrs)

    assert changeset.changes.encrypted_password !== nil
  end
end
