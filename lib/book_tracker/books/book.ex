defmodule BookTracker.Books.Book do
  use Ecto.Schema
  import Ecto.Changeset

  schema "books" do
    field :title, :string
    field :page_count, :integer
    field :summary, :string
    field :isbn10, :string
    field :isbn13, :string
    many_to_many :authors, BookTracker.Authors.Author, join_through: "authors_books"
    many_to_many :genres, BookTracker.Genres.Genre, join_through: "books_genres"

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(book, attrs) do
    book
    |> cast(attrs, [:title, :page_count, :summary, :isbn10, :isbn13])
    |> validate_required([:title, :page_count, :summary, :isbn10, :isbn13])
  end
end
