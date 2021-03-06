defmodule CanvasAPI.Repo.Migrations.CreateAccount do
  use Ecto.Migration

  def change do
    create table(:accounts, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :inserted_at, :timestamptz, null: false
      add :updated_at, :timestamptz, null: false
    end
  end
end
