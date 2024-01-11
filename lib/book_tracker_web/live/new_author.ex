defmodule BookTrackerWeb.NewAuthorLive do
  use BookTrackerWeb, :live_view
  alias BookTracker.Authors
  alias BookTracker.Authors.Author

  @events %{
    "author-submitted" => "Triggered when the user submits the new author form."
  }

  def mount(%{"authorid" => author_id}, _, socket) do
    author = Authors.get_author(String.to_integer(author_id))
    IO.inspect(author, label: "author")
    author_form = to_form(Authors.change_author(author))
    IO.inspect(socket, label: "socket")

    socket
    |> assign(:author_form, author_form)
    |> assign(:author, author)
    |> then(&{:ok, &1})
  end

  def mount(_, _, socket) do
    socket
    |> assign_new_author_form()
    |> then(&{:ok, &1})
  end

  def render(assigns) do
    ~H"""
    <h1 class="mb-4 text-3xl">Add an Author</h1>
    <.form for={@author_form} phx-submit="author-submitted">
      <.input type="text" field={@author_form[:first_name]} label="First Name" />
      <.input type="text" field={@author_form[:last_name]} label="Last Name" />
      <p class="font-semibold">Author Notes</p>
      <p class="text-sm mb-3">accepts markdown input</p>
      <.input type="textarea" field={@author_form[:md_bio_notes]} />
      <.button class="mt-3">Save Author</.button>
    </.form>
    """
  end

  def get_events(), do: @events

  def handle_event("author-submitted", %{"author" => author_params}, socket) do
    db_update_result =
      if author = socket.assigns[:author] do
        Authors.update_author(
          author,
          author_params
        )
      else
        Authors.create_author(author_params)
      end

    case db_update_result do
      {:ok, _} ->
        socket
        |> put_flash(:info, "author added")
        |> push_navigate(to: "/authors/new")
        |> then(&{:noreply, &1})

      {:error, cs} ->
        socket
        |> put_flash(:error, "invalid author info")
        |> assign(:author_form, to_form(cs))
        |> then(&{:noreply, &1})
    end
  end

  defp assign_new_author_form(socket) do
    assign(socket, :author_form, to_form(Authors.change_author(%Author{})))
  end
end
