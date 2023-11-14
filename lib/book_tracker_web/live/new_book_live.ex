defmodule BookTrackerWeb.NewBookLive do
  use BookTrackerWeb, :live_view
  alias BookTracker.Books
  alias BookTracker.Books.Book
  alias BookTrackerWeb.LiveComponents.MatchAndSelect

  def mount(_, _, socket) do
    socket
    |> assign(:book_form, to_form(Books.change_book(%Book{})))
    |> assign(:form_reset, false)
    |> assign(:selected_authors, [])
    |> then(&{:ok, &1})
  end

  def render(assigns) do
    ~H"""
    <h1 class="mb-4 text-3xl">Add a Book</h1>
    <.form for={@book_form} phx-submit="book-submitted">
      <.input type="text" field={@book_form[:title]} label="Title" />
      <.input type="text" field={@book_form[:summary]} label="Summary" />
      <.input type="number" field={@book_form[:page_count]} label="Page Count" />
      <.input type="text" field={@book_form[:isbn10]} label="ISBN-10" />
      <.input type="text" field={@book_form[:isbn13]} label="ISBN-13" />
      <.live_component module={MatchAndSelect} id="author-select" reset={@form_reset} />
      <.button>Add</.button>
    </.form>
    """
  end

  def handle_event("book-submitted", %{"book" => params}, socket) do
    IO.inspect(socket.assigns.selected_authors, label: "selected authors")

    case Books.create_book(params, socket.assigns.selected_authors) do
      {:ok, _} ->
        socket
        |> put_flash(:info, "book added")
        |> assign_new_book_form()
        |> update(:form_reset, &(!&1))
        |> assign(:selected_authors, [])
        |> then(&{:noreply, &1})

      {:error, cs} ->
        {:noreply, assign(socket, :book_form, cs)}
    end
  end

  def handle_info({:selected_update, selected_list}, socket) do
    {:noreply, assign(socket, :selected_authors, selected_list)}
  end

  defp assign_new_book_form(socket) do
    assign(socket, :book_form, to_form(Books.change_book_authors(%Book{})))
  end
end
