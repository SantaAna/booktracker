defmodule BookTracker.BooksTest do
  use BookTracker.DataCase

  alias BookTracker.Books

  describe "books" do
    alias BookTracker.Books.Book

    import BookTracker.BooksFixtures

    @invalid_attrs %{title: nil, page_count: nil, summary: nil, isbn10: nil, isbn13: nil}

    test "list_books/0 returns all books" do
      book = book_fixture()
      assert Books.list_books() == [book]
    end

    test "get_book!/1 returns the book with given id" do
      book = book_fixture()
      assert Books.get_book!(book.id) == book
    end

    test "create_book/1 with valid data creates a book" do
      valid_attrs = %{title: "some title", page_count: 42, summary: "some summary", isbn10: "some isbn10", isbn13: "some isbn13"}

      assert {:ok, %Book{} = book} = Books.create_book(valid_attrs)
      assert book.title == "some title"
      assert book.page_count == 42
      assert book.summary == "some summary"
      assert book.isbn10 == "some isbn10"
      assert book.isbn13 == "some isbn13"
    end

    test "create_book/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Books.create_book(@invalid_attrs)
    end

    test "update_book/2 with valid data updates the book" do
      book = book_fixture()
      update_attrs = %{title: "some updated title", page_count: 43, summary: "some updated summary", isbn10: "some updated isbn10", isbn13: "some updated isbn13"}

      assert {:ok, %Book{} = book} = Books.update_book(book, update_attrs)
      assert book.title == "some updated title"
      assert book.page_count == 43
      assert book.summary == "some updated summary"
      assert book.isbn10 == "some updated isbn10"
      assert book.isbn13 == "some updated isbn13"
    end

    test "update_book/2 with invalid data returns error changeset" do
      book = book_fixture()
      assert {:error, %Ecto.Changeset{}} = Books.update_book(book, @invalid_attrs)
      assert book == Books.get_book!(book.id)
    end

    test "delete_book/1 deletes the book" do
      book = book_fixture()
      assert {:ok, %Book{}} = Books.delete_book(book)
      assert_raise Ecto.NoResultsError, fn -> Books.get_book!(book.id) end
    end

    test "change_book/1 returns a book changeset" do
      book = book_fixture()
      assert %Ecto.Changeset{} = Books.change_book(book)
    end
  end
end
