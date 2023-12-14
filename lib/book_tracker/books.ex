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
  Searches through the books table with the given options, returns a tuple where the first element is the number of pages of results and the second is the list of matching book structs.

  ## Options
  - `:page_size` - the number of results that will be returned, defaults to 5
  - `:current_page` - the page of results that should be returned, defaults to 1
  - `:author_first_name` - the first name of the author, will be searched using postgres like. Defaults to nil in which case no first name filtering is performed.
  - `:author_last_name` - the last name of the author, will be searched using postgres like. Defaults to nil in which case no last name filtering is performed.
  """
  def search(options) do
    defaults = [
      page_size: 5,
      current_page: 1,
      author_first_name: nil,
      author_last_name: nil
    ]

    options = Keyword.merge(defaults, options)

    q =
      from b in Book,
        preload: [:authors, :genres]

    q
    |> maybe_join_books_with_authors(options)
    |> maybe_get_by_first_name(options)
    |> maybe_get_by_last_name(options)
    |> distinct(true)
    |> then(
      &{maximum_page_count(&1, options[:page_size]),
       get_books_on_page(&1, options[:current_page], options[:page_size]) |> Repo.all()}
    )
  end

  defp maybe_join_books_with_authors(q, options) do
    if options[:author_first_name] || options[:author_last_name] do
      join_books_with_authors(q)
    else
      q
    end
  end

  defp maybe_get_by_first_name(q, options) do
    if first_name = options[:author_first_name] do
      get_books_with_author_first_name(q, first_name)
    else
      q
    end
  end

  defp maybe_get_by_last_name(q, options) do
    if last_name = options[:author_last_name] do
      get_books_with_author_last_name(q, last_name)
    else
      q
    end
  end

  defp join_books_with_authors(q) do
    from b in q,
      as: :book,
      join: ab in "authors_books",
      on: b.id == ab.book_id,
      join: a in Author,
      as: :author,
      on: a.id == ab.author_id
  end

  defp get_books_with_author_first_name(q, first_name) do
    from [author: a] in q,
      where: like(a.first_name, ^"#{first_name}%")
  end

  defp get_books_with_author_last_name(q, last_name) do
    from [author: a] in q,
      where: like(a.last_name, ^"#{last_name}%")
  end

  defp get_books_on_page(q, page_number, page_size)
       when is_integer(page_number) and is_integer(page_size) do
    from(b in q)
    |> limit_books(page_size)
    |> offset_books(calculate_offset(page_size, page_number))
  end

  defp maximum_page_count(q, page_size) do
    record_count = Repo.aggregate(q, :count)

    case rem(record_count, page_size) do
      0 ->
        div(record_count, page_size)

      _ ->
        div(record_count, page_size) + 1
    end
  end

  defp calculate_offset(page_size, page_number) do
    (page_number - 1) * page_size
  end

  defp limit_books(q, limit) when is_integer(limit) do
    from b in q,
      limit: ^limit
  end

  defp offset_books(q, offset) when is_integer(offset) do
    from b in q,
      offset: ^offset
  end
end
