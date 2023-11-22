defmodule BookTrackerWeb.NewAuthor do
  use BookTrackerWeb, :live_view
  alias BookTracker.Authors
  alias BookTracker.Authors.Author

  def mount(_, _, socket) do
    socket
    |> assign_new_author_form()
    |> then(& {:ok, &1})
  end

  def render(assigns) do
  ~H"""
    <h1> you've made it to the author page! </h1>
  """    
  end

  defp assign_new_author_form(socket) do
    assign(socket, :author_form, to_form(Authors.change_author(%Author{})))
  end
end
