defmodule BookTrackerWeb.NewBookLive do
  use BookTrackerWeb, :live_view
  alias BookTracker.Books.Book
  alias BookTracker.Authors.Author
  alias BookTracker.Genres.Genre
  alias BookTracker.{Authors, Books, Genres}
  alias BookTrackerWeb.LiveComponents.MatchAndSelect

  @events %{
    "book-submitted" => "triggered when a user submits the new book form"
  }

  def mount(_, _, socket) do
    socket
    |> assign_new_book_form()
    |> assign_new_genre_form()
    |> assign_new_author_form()
    |> assign(:form_reset, false)
    |> assign(:selected_authors, [])
    |> assign(:selected_genres, [])
    |> then(&{:ok, &1})
  end

  def render(assigns) do
    ~H"""
    <h1 class="mb-4 text-3xl">Add a Book</h1>
    <.form for={@book_form} phx-submit="book-submitted">
      <.input
        class="input input-md input-bordered"
        type="text"
        field={@book_form[:title]}
        label="Title"
      />
      <.input type="number" field={@book_form[:page_count]} label="Page Count" />
      <.input type="text" field={@book_form[:isbn10]} label="ISBN-10" />
      <.input type="text" field={@book_form[:isbn13]} label="ISBN-13" />
      <.input type="date" field={@book_form[:last_read]} label="Last Read" />
      <.rating field={@book_form[:rating]} />
      <div class="relative">
        <.live_component
          module={MatchAndSelect}
          id="genre-select"
          reset={@form_reset}
          match_function={&Genres.get_genre_by_name/2}
          input_label="Genres"
          input_identifier="genres"
          match_label="Matching Genres"
          selected_label="Added to Book"
          form_field={@book_form[:genres]}
        />
        <label
          class="btn btn-md btn-success ml-1 mt-9 absolute top-0 left-52"
          for="new-genre-modal"
          id="new-genre-modal-label"
        >
          <.icon name="hero-plus" />
        </label>
      </div>
      <div class="relative">
        <.live_component
          module={MatchAndSelect}
          id="author-select"
          reset={@form_reset}
          match_function={&Authors.get_author_by_name/2}
          input_label="Authors"
          input_identifier="authors"
          match_label="Matching Authors"
          selected_label="Added to Book"
          form_field={@book_form[:genres]}
        />
        <label
          class="btn btn-md btn-success ml-1 mt-9 absolute top-0 left-52"
          for="new-author-modal"
          id="new-author-modal-label"
        >
          <.icon name="hero-plus" />
        </label>
      </div>
      <p class="font-semibold">Summary</p>
      <p class="text-sm mb-3">accepts markdown input</p>
      <.input type="textarea" field={@book_form[:md_summary]} />
      <button class="btn btn-primary mt-2">Save Book</button>
    </.form>
    <.add_new_modal id="new-genre-modal" title="Add Genre">
      <.form for={@genre_form} phx-submit="genre-submitted">
        <.input field={@genre_form[:name]} type="text" label="Genre Name" />
        <button class="btn btn-primary mt-2">Create Genre</button>
      </.form>
    </.add_new_modal>
    <.add_new_modal id="new-author-modal" title="Add Author">
      <.form for={@author_form} phx-submit="author-submitted">
        <.input field={@author_form[:first_name]} type="text" label="First Name" />
        <.input field={@author_form[:last_name]} type="text" label="Last Name" />
        <.input field={@author_form[:md_bio_notes]} type="textarea" label="Biography Note" />
        <button class="btn btn-primary mt-2">Create Author</button>
      </.form>
    </.add_new_modal>
    """
  end

  attr :field, :string, required: true

  def rating(assigns) do
    ~H"""
    <fieldset class="mt-2 mb-2">
      <legend>Book Rating</legend>
        <div class="rating">
          <.input
            type="radio"
            value="1"
            class="mask mask-star-2"
            field={@field}
          />
          <.input
            type="radio"
            value="2"
            class="mask mask-star-2"
            field={@field}
          />
          <.input
            type="radio"
            value="3"
            class="mask mask-star-2"
            field={@field}
          />
          <.input
            type="radio"
            value="4"
            class="mask mask-star-2"
            field={@field}
          />
          <.input
            type="radio"
            value="5"
            class="mask mask-star-2"
            field={@field}
          />
        </div>
    </fieldset>
    """
  end

  @doc """
  Renders a modal that is used to enter info for a new item.

  The inner block should be a form.
  """
  attr :id, :string, required: true
  slot :inner_block, required: true
  attr :title, :string, default: nil

  def add_new_modal(assigns) do
    ~H"""
    <input type="checkbox" id={@id} class="modal-toggle" />
    <div class="modal" role="dialog">
      <div class="modal-box">
        <div class="flex flex-row justify-end">
          <div class="modal-action mb-5">
            <label
              for={@id}
              class="bg-error text-error-content text-lg cursor-pointer rounded-full p-1 hover:bg-red-800"
            >
              &#x1F7AE Close
            </label>
          </div>
        </div>
        <h3 :if={@title} class="text-xl mb-3">
          <%= @title %>
        </h3>
        <%= render_slot(@inner_block) %>
      </div>
    </div>
    """
  end

  def get_events(), do: @events

  def handle_event("genre-submitted", %{"genre" => params}, socket) do
    case Genres.create_genre(params) do
      {:ok, _} ->
        socket
        |> put_flash(:info, "genre added")
        |> assign_new_genre_form()
        |> then(&{:noreply, &1})

      {:error, cs} ->
        socket
        |> put_flash(:error, translate_errors(cs))
        |> assign_new_genre_form()
        |> then(&{:noreply, &1})
    end
  end

  def handle_event("author-submitted", %{"author" => params}, socket) do
    case Authors.create_author(params) do
      {:ok, _} ->
        socket
        |> put_flash(:info, "author added")
        |> assign_new_author_form()
        |> then(&{:noreply, &1})

      {:error, cs} ->
        socket
        |> put_flash(:error, translate_errors(cs))
        |> assign_new_author_form()
        |> then(&{:noreply, &1})
    end
  end

  def handle_event("book-submitted", %{"book" => params}, socket) do
    IO.inspect(params, label: "new book params")
    case Books.create_book(
           params,
           socket.assigns.selected_authors,
           socket.assigns.selected_genres
         ) do
      {:ok, _} ->
        socket
        |> put_flash(:info, "book added")
        |> push_navigate(to: "/books/new")
        |> then(&{:noreply, &1})

      {:error, cs} ->
        IO.inspect(cs, label: "cs returned")
        IO.inspect(to_form(cs)[:authors], label: "authors field")
        {:noreply, assign(socket, :book_form, to_form(cs))}
    end
  end

  def handle_info({:selected_update, "authors", selected_list}, socket) do
    {:noreply, assign(socket, :selected_authors, selected_list)}
  end

  def handle_info({:selected_update, "genres", selected_list}, socket) do
    {:noreply, assign(socket, :selected_genres, selected_list)}
  end

  defp assign_new_book_form(socket) do
    assign(socket, :book_form, to_form(Books.change_book_authors(%Book{})))
  end

  defp assign_new_author_form(socket) do
    assign(socket, :author_form, to_form(Authors.change_author(%Author{})))
  end

  defp assign_new_genre_form(socket) do
    assign(socket, :genre_form, to_form(Genres.change_genre(%Genre{})))
  end

  defp translate_errors(cs) do
    Enum.map(Keyword.keys(cs.errors), fn error ->
      "#{error}: #{elem(cs.errors[error], 0)}"
    end)
    |> Enum.join("\n")
  end
end
