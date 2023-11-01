defmodule BookTracker.AuthorsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `BookTracker.Authors` context.
  """

  @doc """
  Generate a author.
  """
  def author_fixture(attrs \\ %{}) do
    {:ok, author} =
      attrs
      |> Enum.into(%{
        bio_notes: "some bio_notes",
        first_name: "some first_name",
        last_name: "some last_name"
      })
      |> BookTracker.Authors.create_author()

    author
  end
end
