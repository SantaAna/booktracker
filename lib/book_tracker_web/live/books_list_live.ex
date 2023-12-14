defmodule BookTrackerWeb.BooksListLive do
  use BookTrackerWeb, :live_view
  alias BookTracker.Books

  @default_params %{
    "page-size" => "5",
    "page" => "1",
    "author-name" => "",
    "genres" => ""
  }

  def mount(_, _, socket) do
    {:ok, socket}
  end

  def handle_params(params, _uri, socket) do
    params = Map.merge(@default_params, params)

    [first_name, last_name] = extract_first_and_last(params["author-name"])
    genres = extract_genres(params["genres"])

    {maximum_pages, books} =
      Books.search(
        current_page: String.to_integer(params["page"]),
        page_size: String.to_integer(params["page-size"]),
        author_first_name: first_name,
        author_last_name: last_name,
        genres: genres
      )

    socket
    |> assign(:books, books)
    |> assign(:author_name, params["author-name"])
    |> assign(:page_size, String.to_integer(params["page-size"]))
    |> assign(:page, String.to_integer(params["page"]))
    |> assign(:max_page, maximum_pages)
    |> assign(:genres, params["genres"])
    |> assign(:params, params)
    |> then(&{:noreply, &1})
  end

  def render(assigns) do
    ~H"""
    <form phx-submit="search-params-updated">
      <label for="page-size"> Books Per Page </label>
      <input
        type="number"
        name="page-size"
        id="page-size"
        placeholder={@page_size}
        value={@page_size}
      />
      <label for="author-name">Author Name</label>
      <input type="text" name="author-name" id="author-name" value={@author_name} />
      <label for="genres">Genres</label>
      <input type="text" name="genres" id="genres" value={@genres} />
      <.button>Submit</.button>
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
          <.link
            navigate={~p"/books/#{book.id}"}
            class="underline underline-offset-2 hover:text-sky-700"
          >
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
        <.link patch={~p"/books?#{decrement_page(@params)}"}>
          Prev
        </.link>
      </div>
      <div :if={@page < @max_page} class="rounded-r-lg p-2 text-right bg-gray-100">
        <.link patch={~p"/books?#{increment_page(@params)}"}>
          Next
        </.link>
      </div>
    </div>
    """
  end

  defp increment_page(params) when is_map(params) do
    Map.update!(params, "page", &(String.to_integer(&1) + 1))
  end

  defp decrement_page(params) when is_map(params) do
    Map.update!(params, "page", &(String.to_integer(&1) - 1))
  end

  def handle_event("search-params-updated", params, socket) do
    {:noreply, push_patch(socket, to: ~p"/books?#{params}")}
  end

  defp extract_first_and_last(author_name) do
    case String.split(author_name, " ", parts: 2) do
      [first_name, last_name] ->
        [first_name, last_name]

      [first_name] ->
        [first_name, nil]

      _ ->
        [nil, nil]
    end
  end

  defp extract_genres(genre_string) when is_binary(genre_string) do
    String.split(genre_string, ",", trim: true)
    |> then(&if &1 == [], do: nil, else: &1)
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
