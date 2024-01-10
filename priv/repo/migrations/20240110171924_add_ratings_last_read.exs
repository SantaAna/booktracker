defmodule BookTracker.Repo.Migrations.AddRatingsLastRead do
  use Ecto.Migration

  def change do
    alter table(:books) do
      add :rating, :integer 
      add :last_read, :date
    end 
  end
end
