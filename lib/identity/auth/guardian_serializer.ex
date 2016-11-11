defmodule Identity.Auth.GuardianSerializer do
  @moduledoc """
  The Token serializer used by Guardian to encode and
  decode resources into and from JWTs.
  """

  @behaviour Guardian.Serializer

  alias Identity.Repo
  alias Identity.User

  def for_token(user = %User{}), do: {:ok, "User:#{user.id}"}
  def for_token(_), do: {:error, "Unknown resource type"}

  def from_token("User:" <> id), do: {:ok, Repo.get(User, id)}
  def from_token(_), do: {:error, "Unknown resource type"}

end
