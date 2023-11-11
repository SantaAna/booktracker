defmodule BookTrackerWeb.LiveComponents.MatchAndSelect do
  use BookTrackerWeb, :live_component

  @events %{
    "author-selected" => "indicates that an author has been selected by the user."
  }

  def update(assigns, socket) do
    assigns =
      Map.merge(assigns, socket.assigns)
      |> Map.put(:author_input, "")
      |> Map.put(:author_matches, [
        %{
          first_name: "dirk",
          last_name: "struthers",
          id: 1
        }
      ])
      |> Map.put(:selected_authors, [])

    {:ok, Map.put(socket, :assigns, assigns)}
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

  def handle_event("author-selected", %{"selected-author-id" => author_id}, socket) do
    {selected_author, other_suggested} = extract_author_by_id(socket.assigns.author_matches, author_id)
    socket
    |> update(:selected_authors, & [selected_author | &1])
    |> assign(:author_matches, other_suggested)
    |> then(& {:noreply, &1})
  end

  def handle_event("update-author", params, socket) do
    IO.inspect(params, label: "params from change event")
    {:noreply, socket}
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

  def get_events(), do: @events
end
