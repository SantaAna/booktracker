defmodule BookTracker.Repo.Migrations.CreateAuthors do
  use Ecto.Migration

  def change do
    create table(:authors) do
      add :first_name, :string
      add :last_name, :string
      add :bio_notes, :text

      timestamps(type: :utc_datetime)
    end
  end
end
