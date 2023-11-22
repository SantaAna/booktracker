defmodule BookTrackerWeb.BookController do
  use BookTrackerWeb, :controller  
  alias BookTracker.Books

  def show(conn, %{"book_id" => book_id}) do
    case Books.get_book(String.to_integer(book_id), [:authors, :genres]) do
      nil ->  
        render(conn, :notfound, book_id: book_id) 
      book ->
        render(conn, :show, book: book)
    end
  end
end
