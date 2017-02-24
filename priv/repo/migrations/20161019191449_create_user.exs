defmodule Identity.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    execute("CREATE EXTENSION citext;")

    create table(:users, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :email, :citext

      timestamps()
    end
    create unique_index(:users, [:email])

  end
end
