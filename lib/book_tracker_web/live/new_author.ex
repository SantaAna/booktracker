defmodule BookTrackerWeb.NewAuthorLive do
  use BookTrackerWeb, :live_view
  alias BookTracker.Authors
  alias BookTracker.Authors.Author

  @events %{
    "author-submitted" => "Triggered when the user submits the new author form."
  }

  def mount(_, _, socket) do
    socket
    |> assign_new_author_form()
    |> then(&{:ok, &1})
  end

  def render(assigns) do
    ~H"""
    <h1 class="mb-4 text-3xl">Add an Author</h1>
    <.form for={@author_form} phx-submit="author-submitted">
      <.input type="text" field={@author_form[:first_name]} label="First Name"/> 
      <.input type="text" field={@author_form[:last_name]} label="Last Name"/> 
      <.input type="hidden" field={@author_form[:bio_notes]} id="bio-notes"/>
      <p class="mb-3 mt-3 font-semibold text-sm"> Author Notes </p>
      <div phx-update="ignore" id="bio-editor">
        <trix-editor for="bio-notes" class="pt-3">
        </trix-editor>
      </div>
    <.button class="mt-3"> Save Author </.button>
    </.form>
    """
  end

  def get_events(), do: @events

  def handle_event("author-submitted", %{"author" => author_params}, socket) do
    case Authors.create_author(author_params) do
      {:ok, _} -> 
        socket
        |> put_flash(:info, "author added")
        |> push_navigate(to: "/authors/new")
        |> then(& {:noreply, &1})
      {:error, cs}-> 
        socket
        |> put_flash(:error, "invalid author info")
        |> assign(:author_form, to_form(cs))
        |> then(& {:noreply, &1})
    end
  end

  defp assign_new_author_form(socket) do
    assign(socket, :author_form, to_form(Authors.change_author(%Author{})))
  end

end
