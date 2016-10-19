defmodule Identity.User do
  use Identity.Web, :model

  schema "users" do
    field :name, :string
    field :email, :string

    has_many :authorizations, Identity.Authorization

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :email])
    |> validate_required([:name, :email])
    |> validate_format(:email, ~r/(\w+)@([\w.]+)/)
    |> unique_constraint(:email)
  end
end
