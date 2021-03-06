defmodule Identity.Repo.Migrations.CreateAuthorization do
  use Ecto.Migration

  def change do
    create table(:authorizations, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :provider, :string
      add :uid, :string
      add :token, :string
      add :refresh_token, :string
      add :expires_at, :integer
      add :user_id, references(:users, on_delete: :delete_all, type: :binary_id)

      timestamps()
    end

    create unique_index(:authorizations, [:provider, :uid])
    create index(:authorizations, [:expires_at])
    create index(:authorizations, [:provider, :token])

  end
end
