defmodule Identity.User do
  use Identity.Web, :model

  import Comeonin.Bcrypt, only: [hashpwsalt: 1]

  schema "users" do
    field :name, :string
    field :email, :string
    field :encrypted_password, :string
    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true

    has_many :authorizations, Identity.Authorization

    timestamps()
  end

  @required_fields ~w(name email password password_confirmation)a
  @optional_fields ~w()a

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @required_fields, @optional_fields)
    |> validate_required(@required_fields)
    |> validate_format(:email, ~r/(\w+)@([\w.]+)/)
    |> validate_length(:password, min: 1)
    |> validate_length(:password_confirmation, min: 1)
    |> validate_confirmation(:password)
    |> unique_constraint(:email)
  end

  def changeset_with_password(struct, params \\ %{}) do
    changeset = __MODULE__.changeset(struct, params)

    case changeset.valid? do
      true -> changeset |> change(encrypted_password: hashpwsalt(changeset.changes[:password]))
      _    -> changeset
    end
  end
end
