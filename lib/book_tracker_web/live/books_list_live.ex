defmodule BookTrackerWeb.BooksListLive do
  use BookTrackerWeb, :live_view
  alias BookTracker.Books

  @default_params %{
    "page-size" => "5",
    "page" => "1",
    "author-name" => "",
    "genres" => "",
    "title" => ""
  }

  def mount(_, _, socket) do
    {:ok, socket}
  end

  def handle_params(params, _uri, socket) do
    params = Map.merge(@default_params, params)
    [first_name, last_name] = extract_first_and_last(params["author-name"])
    title = if params["title"] == "", do: nil, else: params["title"]

    genres = extract_genres(params["genres"])

    {maximum_pages, books} =
      Books.search(
        current_page: String.to_integer(params["page"]),
        page_size: String.to_integer(params["page-size"]),
        author_first_name: first_name,
        author_last_name: last_name,
        genres: genres,
        title: title
      )

    socket
    |> assign(:books, books)
    |> assign(:max_page, maximum_pages)
    |> assign(:params, params)
    |> assign(:headers, ["Title", "Authors", "Genres", "Rating", "Pages", "Last Read"])
    |> then(&{:noreply, &1})
  end

  def render(assigns) do
    ~H"""
    <div class="card shadow-xl">
      <div class="card-body">
        <h2 class="card-title">Search Criteria</h2>
        <form phx-submit="search-params-updated">
          <div class="grid grid-cols-2">
            <.search_input label="Title" id="title" type="text" value={@params["title"]} />
            <.search_input
              label="Author Name"
              id="author-name"
              type="text"
              value={@params["author-name"]}
            />
            <.search_input label="Genres" id="genres" type="text" value={@params["genres"]} />
            <.search_input
              label="Books Per Page"
              id="page-size"
              type="number"
              value={@params["page-size"]}
            />
          </div>
          <button class="btn btn-primary mt-2">Submit</button>
        </form>
      </div>
    </div>
    <div class="pt-4">
      <table class="table table-zebra w-full">
        <.table_head headers={@headers} />
        <tr :for={book <- @books}>
          <.table_data :for={header <- @headers} book={book} header={header} />
        </tr>
      </table>
    </div>
    <div class="flex flex-row justify-center gap-1 pt-3">
      <div :if={String.to_integer(@params["page"]) > 1}>
        <.link patch={~p"/books?#{decrement_page(@params)}"}>
          <div class="btn rounded-r-none">
            <.icon name="hero-arrow-left-solid" class="h-4 w-4" /> Prev
          </div>
        </.link>
      </div>
      <div :if={String.to_integer(@params["page"]) < @max_page}>
        <.link patch={~p"/books?#{increment_page(@params)}"}>
          <div class="btn rounded-l-none">
            Next <.icon name="hero-arrow-right-solid" class="h-4 w-4" />
          </div>
        </.link>
      </div>
    </div>
    """
  end

  attr :label, :string, required: true
  attr :value, :string, required: true
  attr :id, :string, required: true
  attr :type, :string, required: true

  def search_input(assigns) do
    ~H"""
    <div>
      <label for={@id} class="label label-text"><%= @label %></label>
      <input class="input input-md input-bordered" type={@type} name={@id} id={@id} value={@value} />
    </div>
    """
  end

  attr :headers, :list, required: true

  def table_head(assigns) do
    ~H"""
    <thead>
      <tr>
        <th :for={header <- @headers}>
          <%= header %>
        </th>
      </tr>
    </thead>
    """
  end

  attr :header, :string, required: true
  attr :book, :map, required: true

  def table_data(%{header: "Title"} = assigns) do
    ~H"""
    <td>
      <.link navigate={~p"/books/#{@book.id}"} class="link link-primary">
        <%= @book.title %>
      </.link>
    </td>
    """
  end

  def table_data(%{header: "Authors"} = assigns) do
    ~H"""
    <td><.authors_to_links authors={@book.authors} /></td>
    """
  end

  def table_data(%{header: "Genres"} = assigns) do
    ~H"""
    <td><%= genres_to_names(@book.genres) %></td>
    """
  end

  def table_data(%{header: "Pages"} = assigns) do
    ~H"""
    <td><%= @book.page_count %></td>
    """
  end

  def table_data(%{header: "Rating"} = assigns) do
    ~H"""
    <td><%= @book.rating %>/5</td>
    """
  end

  def table_data(%{header: "Last Read"} = assigns) do
    ~H"""
    <td><%= if @book.last_read, do: Date.to_string(@book.last_read), else: "" %></td>
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

  def authors_to_links(assigns) do
    ~H"""
    <div class="flex flex-row gap-1">
      <.link :for={author <- @authors} navigate={~p"/authors/#{author.id}"} class="link link-primary">
        <%= author.first_name %> <%= author.last_name %>
      </.link>
    </div>
    """
  end

  defp genres_to_names(genres) do
    genres
    |> Enum.map(& &1.name)
    |> Enum.join(", ")
  end
end
