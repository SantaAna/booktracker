defmodule BookTrackerWeb.BookComponents do
  use BookTrackerWeb, :html

  attr :book, :map, required: true

  def book_card(assigns) do
    ~H"""
    <.link navigate={~p"/books/#{@book.id}"}> 
    <div class="bg-gray-300 p-4 rounded-md flex-col">
      <div class="text-lg"><%= @book.title %></div>
      <div> Pages: <%= @book.page_count %> </div>
      <div> 
        Genres:
        <span :for={genre <- @book.genres}> <%= genre.name %> </span> 
      </div>
    </div>
    </.link>
    """
  end
end
