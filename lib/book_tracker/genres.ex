defmodule BookTracker.Genres do
  @moduledoc """
  The Genres context.
  """

  import Ecto.Query, warn: false
  alias BookTracker.Repo

  alias BookTracker.Genres.Genre

  @doc """
  Returns the list of genres.

  ## Examples

      iex> list_genres()
      [%Genre{}, ...]

  """
  def list_genres do
    Repo.all(Genre)
  end

  @doc """
  Gets a single genre.

  Raises `Ecto.NoResultsError` if the Genre does not exist.

  ## Examples

      iex> get_genre!(123)
      %Genre{}

      iex> get_genre!(456)
      ** (Ecto.NoResultsError)

  """
  def get_genre!(id), do: Repo.get!(Genre, id)

  @doc """
  Creates a genre.

  ## Examples

      iex> create_genre(%{field: value})
      {:ok, %Genre{}}

      iex> create_genre(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_genre(attrs \\ %{}) do
    %Genre{}
    |> Genre.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a genre.

  ## Examples

      iex> update_genre(genre, %{field: new_value})
      {:ok, %Genre{}}

      iex> update_genre(genre, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_genre(%Genre{} = genre, attrs) do
    genre
    |> Genre.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a genre.

  ## Examples

      iex> delete_genre(genre)
      {:ok, %Genre{}}

      iex> delete_genre(genre)
      {:error, %Ecto.Changeset{}}

  """
  def delete_genre(%Genre{} = genre) do
    Repo.delete(genre)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking genre changes.

  ## Examples

      iex> change_genre(genre)
      %Ecto.Changeset{data: %Genre{}}

  """
  def change_genre(%Genre{} = genre, attrs \\ %{}) do
    Genre.changeset(genre, attrs)
  end

  @doc """
  Given a string will find case insensitive matches in the genre
  table for that string.
  
  If a limit option is passed in it will be used to limit the output of the query.
  """
  def get_genre_by_name(name, opts \\ [])
  def get_genre_by_name("", _opts), do: []
  def get_genre_by_name(name, opts) when is_binary(name) and is_list(opts) do
    genre_match_string = leading_match_maker(name)
    opts = get_genre_default_opts(opts)

    q = from g in Genre,
      where: ilike(g.name, ^genre_match_string),
      limit: ^Keyword.get(opts, :limit)

    Repo.all(q)
  end

  def get_genre_by_name(_n, _o) do
    raise(ArgumentError, "invalid arguments, require string for genre match.  May pass keyword list as options")
  end

  def leading_match_maker(string), do: "#{string}%"
  defp get_genre_default_opts(opts), do: Keyword.merge([limit: 3], opts)
end
