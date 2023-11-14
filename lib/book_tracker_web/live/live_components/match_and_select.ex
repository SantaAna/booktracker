defmodule BookTrackerWeb.LiveComponents.MatchAndSelect do
  use BookTrackerWeb, :live_component
  alias BookTracker.Authors

  @events %{
    "author-selected" => "author has been selected by the user.",
    "update-author" => "author text field has changed",
    "author-removed" => "selected author has been clicked, indicated removal"
  }

  def update(_assigns, socket) do
      socket
      |> assign(:author_input, "")
      |> assign(:author_matches, [])
      |> assign(:selected_authors, [])
      |> then(&{:ok, &1})
  end

  def render(assigns) do
    ~H"""
    <div>
      <.input
        type="text"
        label="Author"
        name="author"
        value=""
        phx-change="update-author"
        phx-debounce="500"
        phx-target={@myself}
      />
      <div class="flex flex-row">
        <.author_match :for={author <- @author_matches} author={author} target={@myself} />
      </div>
      <div class="flex flex-row">
        <.author_selected :for={author <- @selected_authors} author={author} target={@myself} />
      </div>
    </div>
    """
  end

  attr :author, :map, required: true
  attr :target, :any, required: true

  def author_match(assigns) do
    ~H"""
    <div phx-click="author-selected" phx-value-selected-author-id={@author.id} phx-target={@target} class="text-yellow-600">
      <%= "#{@author.first_name} #{@author.last_name}" %>
    </div>
    """
  end

  attr :author, :map, required: true
  attr :target, :any, required: true

  def author_selected(assigns) do
    ~H"""
    <div phx-click="author-removed" phx-value-selected-author-id={@author.id} phx-target={@target} class="text-green-400">
      <%= "#{@author.first_name} #{@author.last_name}" %>
    </div>
    """
  end

  def handle_event("author-removed", _params = %{"selected-author-id" => author_id}, socket) do
    update(socket, :selected_authors, fn current -> 
      Enum.reject(current, fn selected -> 
        selected.id == String.to_integer(author_id)
      end)
    end)
    |> notify_parent()
    |> then(& {:noreply, &1})
  end

  def handle_event("author-selected", %{"selected-author-id" => author_id}, socket) do
    {selected_author, other_suggested} = extract_author_by_id(socket.assigns.author_matches, author_id)
    socket
    |> update(:selected_authors, & [selected_author | &1])
    |> assign(:author_matches, other_suggested)
    |> notify_parent()
    |> then(& {:noreply, &1})
  end

  def handle_event("update-author", _params = %{"author" => author_name}, socket) do
    display_matches = Authors.get_author_by_name(author_name, limit: 3)  
    |> Enum.reject(fn match -> match in socket.assigns.selected_authors end)

    {:noreply, assign(socket, :author_matches, display_matches)}
  end

  def extract_author_by_id(author_list, id) when is_binary(id) do
    extract_author_by_id(author_list, String.to_integer(id))
  end

  def extract_author_by_id(author_list, id) do
    {author, reved} =
      Enum.reduce(author_list, {nil, []}, fn
        author = %{id: ^id}, {nil, new_list} -> {author, new_list}
        author, {found, list} -> {found, [author | list]}
      end)

    {author, Enum.reverse(reved)}
  end

  defp notify_parent(socket) do
    send(self(), {:selected_update, socket.assigns.selected_authors})
    socket
  end

  def get_events(), do: @events
end
