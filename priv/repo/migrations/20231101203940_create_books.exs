defmodule BookTracker.Repo.Migrations.CreateBooks do
  use Ecto.Migration

  def change do
    create table(:books) do
      add :title, :string
      add :page_count, :integer
      add :summary, :text
      add :isbn10, :string
      add :isbn13, :string

      timestamps(type: :utc_datetime)
    end
  end
end
