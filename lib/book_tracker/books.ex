defmodule BookTracker.Books do
  @moduledoc """
  The Books context.
  """

  import Ecto.Query, warn: false
  alias BookTracker.Repo

  alias BookTracker.Books.Book
  alias BookTracker.Authors.Author
  alias BookTracker.AuthorsBooks.AuthorBook

  @doc """
  Returns the list of books.

  ## Examples

      iex> list_books()
      [%Book{}, ...]

  """
  def list_books do
    Repo.all(Book)
  end

  def list_books(preloads) when is_list(preloads) do
    Repo.all(Book)
    |> Repo.preload(preloads)
  end

  @doc """
  Gets a single book.

  Raises `Ecto.NoResultsError` if the Book does not exist.

  ## Examples

      iex> get_book!(123)
      %Book{}

      iex> get_book!(456)
      ** (Ecto.NoResultsError)

  """
  def get_book!(id), do: Repo.get!(Book, id)

  @doc """
  As get_book! but will return nil if the record is not found.
  """
  def get_book(id, preloads \\ []), do: Repo.get(Book, id) |> Repo.preload(preloads)

  @doc """
  Creates a book.

  ## Examples

      iex> create_book(%{field: value})
      {:ok, %Book{}}

      iex> create_book(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_book(attrs \\ %{}) do
    %Book{}
    |> Book.changeset(attrs)
    |> Repo.insert()
  end

  def create_book(attrs, authors) when is_list(authors) do
    %Book{}
    |> Book.changeset_with_authors(attrs, authors)
    |> Repo.insert()
  end

  def create_book(attrs, authors, genres) when is_list(authors) and is_list(genres) do
    %Book{}
    |> Book.changeset_with_authors_and_genres(attrs, authors, genres)
    |> Repo.insert()
  end

  @doc """
  Updates a book.

  ## Examples

      iex> update_book(book, %{field: new_value})
      {:ok, %Book{}}

      iex> update_book(book, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_book(%Book{} = book, attrs) do
    book
    |> Book.changeset(attrs)
    |> Repo.update()
  end

  def add_author(
        %Book{} = book,
        author_info = %{"first_name" => _first_name, "last_name" => _last_name}
      ) do
    {:ok, author} = BookTracker.Authors.create_author(author_info)
    add_author(book, author)
  end

  def add_author(%Book{id: book_id}, %Author{id: author_id}) do
    Repo.insert(%AuthorBook{book_id: book_id, author_id: author_id})
  end

  @doc """
  Deletes a book.

  ## Examples

      iex> delete_book(book)
      {:ok, %Book{}}

      iex> delete_book(book)
      {:error, %Ecto.Changeset{}}

  """
  def delete_book(%Book{} = book) do
    Repo.delete(book)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking book changes.

  ## Examples

      iex> change_book(book)
      %Ecto.Changeset{data: %Book{}}

  """
  def change_book(%Book{} = book, attrs \\ %{}) do
    Book.changeset(book, attrs)
  end

  @doc """
  Can raise if a list of author structs is not provided by the caller.
  """
  def change_book_authors(%Book{} = book, attrs \\ %{}, authors \\ []) do
    Book.changeset_with_authors(book, attrs, authors)
  end

  @doc """
  Lists all books on the given page number when given the page size.
  """
  def get_books_on_page(page_number, page_size, preloads \\ [])
      when is_integer(page_number) and is_integer(page_size) do
    from(b in Book)
    |> limit_books(page_size)
    |> offset_books(calculate_offset(page_size, page_number))
    |> Repo.all()
    |> Repo.preload(preloads)
  end


  defp calculate_offset(page_size, page_number) do
    (page_number - 1) * page_size
  end

  def limit_books(q, limit) when is_integer(limit) do
    from b in q,
      limit: ^limit
  end

  def offset_books(q, offset) when is_integer(offset) do
    from b in q,
      offset: ^offset
  end

  def maximum_page_count(page_size) do
    record_count = Repo.aggregate(Book, :count)

    case rem(record_count, page_size) do
      0 ->
        div(record_count, page_size)

      _ ->
        div(record_count, page_size) + 1
    end
  end
end
