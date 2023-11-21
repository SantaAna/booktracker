defmodule BookTrackerWeb.NewBookLive do
  use BookTrackerWeb, :live_view
  alias BookTracker.Books.Book
  alias BookTracker.{Authors, Books, Genres}
  alias BookTrackerWeb.LiveComponents.MatchAndSelect

  def mount(_, _, socket) do
    socket
    |> assign(:book_form, to_form(Books.change_book(%Book{})))
    |> assign(:form_reset, false)
    |> assign(:selected_authors, [])
    |> assign(:selected_genres, [])
    |> then(&{:ok, &1})
  end

  def render(assigns) do
    ~H"""
    <h1 class="mb-4 text-3xl">Add a Book</h1>
    <.form for={@book_form} phx-submit="book-submitted">
      <.input type="text" field={@book_form[:title]} label="Title" />
      <.input type="hidden" field={@book_form[:summary]} id="summary"/>
      <.input type="number" field={@book_form[:page_count]} label="Page Count" />
      <.input type="text" field={@book_form[:isbn10]} label="ISBN-10" />
      <.input type="text" field={@book_form[:isbn13]} label="ISBN-13" />
      <.live_component
        module={MatchAndSelect}
        id="genre-select"
        reset={@form_reset}
        match_function={&Genres.get_genre_by_name/2}
        input_label="Genres"
        input_identifier="genres"
        match_label="Matching Genres"
        selected_label="Added to Book"
      />
      <.live_component
        module={MatchAndSelect}
        id="author-select"
        reset={@form_reset}
        match_function={&Authors.get_author_by_name/2}
        input_label="Authors"
        input_identifier="authors"
        match_label="Matching Authors"
        selected_label="Added to Book"
      />
      <p class="font-semibold mb-3"> Summary </p>
      <trix-editor input="summary">
      </trix-editor>
      <.button class="mt-3">Save Book</.button>
    </.form>
    """
  end

  def handle_event("book-submitted", %{"book" => params}, socket) do
    IO.inspect(socket.assigns.selected_authors, label: "selected authors")
    IO.inspect(socket.assigns.selected_genres, label: "selected genres")

    case Books.create_book(params, socket.assigns.selected_authors, socket.assigns.selected_genres) do
      {:ok, _} ->
        socket
        |> put_flash(:info, "book added")
        |> assign_new_book_form()
        |> update(:form_reset, &(!&1))
        |> assign(:selected_authors, [])
        |> assign(:selected_genres, [])
        |> then(&{:noreply, &1})

      {:error, cs} ->
        IO.inspect(cs, label: "cs returned")
        {:noreply, assign(socket, :book_form, to_form(cs))}
    end
  end

  def handle_info({:selected_update, "authors",selected_list}, socket) do
    {:noreply, assign(socket, :selected_authors, selected_list)}
  end

  def handle_info({:selected_update, "genres",selected_list}, socket) do
    {:noreply, assign(socket, :selected_genres, selected_list)}
  end

  defp assign_new_book_form(socket) do
    assign(socket, :book_form, to_form(Books.change_book_authors(%Book{})))
  end
end
