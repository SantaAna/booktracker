defmodule BookTracker.GenresFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `BookTracker.Genres` context.
  """

  @doc """
  Generate a genre.
  """
  def genre_fixture(attrs \\ %{}) do
    {:ok, genre} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> BookTracker.Genres.create_genre()

    genre
  end
end
