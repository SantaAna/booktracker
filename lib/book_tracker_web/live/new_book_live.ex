defmodule BookTrackerWeb.NewBookLive do
  use BookTrackerWeb, :live_view
  alias BookTracker.Books
  alias BookTracker.Books.Book

  def mount(_, _, socket) do
    socket
    |> assign(:book_form, to_form(Books.change_book_authors(%Book{})))
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
      <.button>Add</.button>
    </.form>
    """
  end

  def handle_event("book-submitted", %{"book" => params}, socket) do
    case Books.create_book(params) do
      {:ok, _} ->
        socket
        |> put_flash(:info, "book added")
        |> assign_new_book_form()
        |> then(&{:noreply, &1})

      {:error, cs} ->
        {:noreply, assign(socket, :book_form, cs)}
    end
  end

  defp assign_new_book_form(socket) do
    assign(socket, :book_form, to_form(Books.change_book_authors(%Book{})))
  end
end
