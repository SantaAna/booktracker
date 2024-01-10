defmodule BookTrackerWeb.AuthorController do
  use BookTrackerWeb, :controller
  alias BookTracker.Authors

  def show(conn, %{"author_id" => author_id}) do
    case Authors.get_author(String.to_integer(author_id), books: :genres) do
      nil ->
        render(conn, :not_found, author_id: author_id)

      author ->
        render(conn, :show, author: author)
    end
  end
end
