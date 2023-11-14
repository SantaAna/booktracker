defmodule BookTracker.AuthorsBooks.AuthorBook do
  use Ecto.Schema

  schema "authors_books" do
    belongs_to :author, BookTracker.Authors.Author
    belongs_to :book, BookTracker.Books.Book
  end
end
