defmodule BookTracker.Repo.Migrations.LinkingTables do
  use Ecto.Migration

  def change do
    create table("authors_books") do
      add :author_id, references("authors")
      add :book_id, references("books")
    end

    create table("books_genres") do
      add :book_id, references("books")
      add :genre_id, references("genres")
    end

    create unique_index("authors_books", [:author_id, :book_id])
    create unique_index("books_genres", [:genre_id, :book_id])
  end
end
