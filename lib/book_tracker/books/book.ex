defmodule BookTracker.Books.Book do
  use Ecto.Schema
  import Ecto.Changeset
  alias BookTracker.Authors.Author
  alias BookTracker.Genres.Genre

  schema "books" do
    field :title, :string
    field :page_count, :integer
    field :summary, :string
    field :md_summary, :string
    field :isbn10, :string
    field :isbn13, :string
    field :rating, :integer
    field :last_read, :date

    many_to_many :authors, BookTracker.Authors.Author,
      join_through: "authors_books",
      on_replace: :delete

    many_to_many :genres, BookTracker.Genres.Genre,
      join_through: "books_genres",
      on_replace: :delete

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(book, attrs) do
    book
    |> cast(attrs, [
      :title,
      :page_count,
      :summary,
      :md_summary,
      :isbn10,
      :isbn13,
      :rating,
      :last_read
    ])
    |> validate_required([:title])
  end

  @doc """
  It is possible for this function to raise at run time if the last two arguments 
  are not lists of author structs and genre structs respectively - it is up to the caller to provide this list!

  Will create a changeset for a new book with the associated authors and genres.
  """
  def changeset_with_authors_and_genres(book, attrs, authors, genres) do
    if all_author_structs?(authors) and all_genre_structs?(genres) do
      changeset(book, attrs)
      |> put_assoc(:genres, genres)
      |> put_assoc(:authors, authors)
      |> validate_non_empty_association(:authors)
      |> validate_non_empty_association(:genres)
    else
      raise(
        ArgumentError,
        "the last two arguments must be a list of author structs and genre structs respectively."
      )
    end
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

  defp validate_non_empty_association(changeset, assoc_name) when is_atom(assoc_name) do
    validate_change(changeset, assoc_name, fn _field, value ->
      if value == [] or value == nil do
        [{assoc_name, "you must chose at least one"}]
      else
        []
      end
    end)
  end

  defp all_author_structs?(authors) when is_list(authors) do
    Enum.reduce(authors, true, fn
      %Author{} = _author, acc -> acc
      _, _ -> false
    end)
  end

  defp all_author_structs?(_authors), do: false

  defp all_genre_structs?(genres) when is_list(genres) do
    Enum.reduce(genres, true, fn
      %Genre{} = _genre, acc -> acc
      _, _ -> false
    end)
  end

  defp all_genre_structs?(_authors), do: false
end
