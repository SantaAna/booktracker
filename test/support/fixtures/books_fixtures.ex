defmodule BookTracker.BooksFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `BookTracker.Books` context.
  """

  @doc """
  Generate a book.
  """
  def book_fixture(attrs \\ %{}) do
    {:ok, book} =
      attrs
      |> Enum.into(%{
        isbn10: "some isbn10",
        isbn13: "some isbn13",
        page_count: 42,
        summary: "some summary",
        title: "some title"
      })
      |> BookTracker.Books.create_book()

    book
  end
end
