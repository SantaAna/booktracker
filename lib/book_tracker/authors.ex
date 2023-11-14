defmodule BookTracker.Authors do
  @moduledoc """
  The Authors context.
  """

  import Ecto.Query, warn: false
  alias BookTracker.Repo

  alias BookTracker.Authors.Author

  @doc """
  Returns the list of authors.

  ## Examples

      iex> list_authors()
      [%Author{}, ...]

  """
  def list_authors do
    Repo.all(Author)
  end

  @doc """
  Gets a single author.

  Raises `Ecto.NoResultsError` if the Author does not exist.

  ## Examples

      iex> get_author!(123)
      %Author{}

      iex> get_author!(456)
      ** (Ecto.NoResultsError)

  """
  def get_author!(id), do: Repo.get!(Author, id)

  @doc """
  Creates a author.

  ## Examples

      iex> create_author(%{field: value})
      {:ok, %Author{}}

      iex> create_author(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_author(attrs \\ %{}) do
    %Author{}
    |> Author.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a author.

  ## Examples

      iex> update_author(author, %{field: new_value})
      {:ok, %Author{}}

      iex> update_author(author, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_author(%Author{} = author, attrs) do
    author
    |> Author.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a author.

  ## Examples

      iex> delete_author(author)
      {:ok, %Author{}}

      iex> delete_author(author)
      {:error, %Ecto.Changeset{}}

  """
  def delete_author(%Author{} = author) do
    Repo.delete(author)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking author changes.

  ## Examples

      iex> change_author(author)
      %Ecto.Changeset{data: %Author{}}

  """
  def change_author(%Author{} = author, attrs \\ %{}) do
    Author.changeset(author, attrs)
  end
  
  @doc """
  Fetches an author by the given name.  Only supports a name given in the format "first_name last_name" or "last_name".

  Returns a list of authors that match the given name string (case insensitive matching is used), an empty list is returned if 
  no matching authors are found or if given an empty string as an argument.

  ## Options
  limit: limits results returned by DB - defaults to 3.
  """
  def get_author_by_name(name, opts \\ [limit: 3])

  def get_author_by_name("", _opts), do: []
  
  def get_author_by_name(name, opts) when is_binary(name) do
    get_author_by_name(String.split(name, " ", trim: true), opts)
  end
  
  def get_author_by_name([first_name], opts) do
    first_name_match = leading_match_maker(first_name)

    q = from a in Author,
      where: ilike(a.first_name, ^first_name_match), 
      limit: ^Keyword.get(opts, :limit)
    Repo.all(q)
  end

  def get_author_by_name([first_name, last_name], opts) do
    [first_name_match, last_name_match] =
      Enum.map([first_name, last_name], &leading_match_maker/1)

    q = from a in Author,
      where: ilike(a.first_name, ^first_name_match),
      where: ilike(a.last_name, ^last_name_match),
      limit: ^Keyword.get(opts, :limit)
    Repo.all(q)
  end


  def get_author_by_name(_invalid, opts), do: raise(ArgumentError, "Must provide author first and last name as a binary or list of binaries.")

  def leading_match_maker(string), do: "#{string}%"
end
