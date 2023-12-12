defmodule BookTrackerWeb.BooksListLive do
  use BookTrackerWeb, :live_view
  alias BookTracker.Books

  def mount(_, _, socket) do
    {:ok, socket}
  end

  def handle_params(%{"page_size" =>  page_size, "page" => page}, _uri, socket) do
    socket
    |> assign(:books, Books.get_books_on_page(String.to_integer(page), String.to_integer(page_size), [:authors, :genres]))
    |> assign(:page_size, String.to_integer(page_size))
    |> assign(:page, String.to_integer(page))
    |> assign(:max_page, Books.maximum_page_count(String.to_integer(page_size)))
    |> then(&{:noreply, &1})
  end

  def handle_params(%{"page_size" =>  page_size}, _uri, socket) do
    socket
    |> assign(:books, Books.get_books_on_page(1, String.to_integer(page_size), [:authors, :genres]))
    |> assign(:page_size, String.to_integer(page_size))
    |> assign(:page, 1)
    |> assign(:max_page, Books.maximum_page_count(String.to_integer(page_size)))
    |> then(&{:noreply, &1})
  end


  def handle_params(_params, _uri, socket) do
    socket
    |> assign(:books, Books.get_books_on_page(1, 5, [:authors, :genres]))
    |> assign(:page_size, 5)
    |> assign(:page, 1)
    |> assign(:max_page, Books.maximum_page_count(5))
    |> then(&{:noreply, &1})
  end


  def render(assigns) do
    ~H"""
    <form phx-submit="search-params-updated">
      <label for="books-per-page"> Books Per Page </label>
      <input type="number" name="books-per-page" id="books-per-page" placeholder={@page_size}/>
    </form>
    <table class="w-full">
      <thead class="border-b-2 border-gray-200 bg-gray-50">
        <tr>
          <th
            :for={header <- ~w(Title Authors Genres Pages)}
            class="p-3 text-sm font-semibold tracking-wide text-left"
          >
            <%= header %>
          </th>
        </tr>
      </thead>
      <tr :for={book <- @books} class="border-b border-gray-300 even:bg-gray-100">
        <td class="p-3 text-sm tracking-wide">
          <.link navigate={~p"/books/#{book.id}"} class="underline underline-offset-2 hover:text-sky-700">
            <%= book.title %>
          </.link>
        </td>
        <td class="p-3 text-sm tracking-wide"><%= authors_to_names(book.authors) %></td>
        <td class="p-3 text-sm tracking-wide"><%= genres_to_names(book.genres) %></td>
        <td class="p-3 text-sm tracking-wide"><%= book.page_count %></td>
      </tr>
    </table>
    <div class="flex flex-row justify-center pt-3 divide-x-4 divide-white ">
      <div :if={@page > 1} class="rounded-l-lg text-left p-2 bg-gray-100"> 
        <.link
          patch={~p"/books?#{[page: (@page - 1), page_size: @page_size]}"}
        >
        Prev
        </.link>
      </div>
      <div :if={@page < @max_page} class="rounded-r-lg p-2 text-right bg-gray-100"> 
        <.link
          patch={~p"/books?#{[page: (@page + 1), page_size: @page_size]}"}
        >
        Next
        </.link>
      </div>
    </div>
    """
  end

  def handle_event("search-params-updated",%{"books-per-page" => books_per_page} , socket) do
    {:noreply, push_patch(socket, to: ~p"/books?#{[page_size: books_per_page]}")}
  end

  defp authors_to_names(authors) do
    authors
    |> Enum.map(&"#{&1.first_name} #{&1.last_name}")
    |> Enum.join(", ")
  end

  defp genres_to_names(genres) do
    genres
    |> Enum.map(& &1.name)
    |> Enum.join(", ")
  end
end
