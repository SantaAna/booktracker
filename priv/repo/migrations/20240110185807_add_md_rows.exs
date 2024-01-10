defmodule BookTracker.Repo.Migrations.AddMdRows do
  use Ecto.Migration
  @moduledoc """
  Adds columns for md content in books and authors
  tables.
  """
  def change do
    alter table(:books) do
      add :md_summary, :text 
    end  

    alter table(:authors) do
      add :md_bio_notes, :text
    end
  end
end
