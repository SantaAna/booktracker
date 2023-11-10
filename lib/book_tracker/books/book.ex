defmodule BookTracker.Books.Book do
  use Ecto.Schema
  import Ecto.Changeset
  alias BookTracker.Authors.Author

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

  @doc """
  It is possible for this function to raise at run time if the third argument 
  is not a list of author structs - it is up to the caller to provide this list!

  Will create a changeset for a new book with the associated authors.
  """
  def changeset_with_authors(book, attrs, authors) do
    if all_author_structs?(authors) do
      changeset(book, attrs)
      |> put_assoc(:authors, authors)
    else 
      raise("You must provide a list of author structs as the last argument!")
    end
  end

  defp all_author_structs?(authors) when is_list(authors) do
    Enum.reduce(authors, true, fn
      %Author{} = _author, acc -> acc
      _, _ -> false
    end)
  end

  defp all_author_structs?(_authors), do: false
end
