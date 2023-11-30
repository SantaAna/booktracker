defmodule BookTrackerWeb.NewGenreLive do
  use BookTrackerWeb, :live_view
  alias BookTracker.Genres.Genre
  alias BookTracker.Genres

  def mount(_,_,socket) do
    socket
    |> assign_new_genre_form()
    |> then(& {:ok, &1})
  end

  def render(assigns) do
    ~H"""
    <h1 class="mb-4 text-3xl">Add a Genre</h1>
    <.form for={@genre_form} phx-submit="genre-submitted">
      <.input type="text" field={@genre_form[:name]} label="Name"/> 
      <.button class="mt-3"> Save Genre </.button>
    </.form>
    """
  end

  def handle_event("genre-submitted", %{"genre" => genre_params}, socket) do
    case Genres.create_genre(genre_params) do
      {:ok, _} ->     
        socket
        |> put_flash(:info, "genre added")
        |> push_navigate(to: "/genres/new")
        |> then(& {:noreply, &1})
      {:error, cs} -> 
        socket
        |> put_flash(:error, "invalid genre info")
        |> assign(:genre_form, to_form(cs))
        |> then(& {:noreply, &1})
        |> dbg()
    end 
  end

  defp assign_new_genre_form(socket) do
    assign(socket, :genre_form, to_form(Genres.change_genre(%Genre{})))
  end
end
