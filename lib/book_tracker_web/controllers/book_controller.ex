defmodule BookTrackerWeb.BookController do
  use BookTrackerWeb, :controller  

  def show(conn, %{"book_id" => book_id}) do
    render(conn, :show, book_id: String.to_integer(book_id))     
  end
end
