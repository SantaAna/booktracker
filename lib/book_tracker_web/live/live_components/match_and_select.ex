defmodule BookTrackerWeb.LiveComponents.MatchAndSelect do
  use BookTrackerWeb, :live_component

  @events %{
    "item-selected" => "item has been selected by the user.",
    "update-item" => "item text field has changed",
    "item-removed" => "selected item has been clicked, indicated removal"
  }

  def update(assigns, socket) do
    socket
    |> assign(assigns)
    |> assign(:item_input, "")
    |> assign(:item_matches, [])
    |> assign(:selected_items, [])
    |> then(&{:ok, &1})
  end

  def render(assigns) do
    ~H"""
    <div>
      <.input
        type="text"
        label={@input_label}
        name={@input_identifier}
        value=""
        phx-change="update-item"
        phx-debounce="500"
        phx-target={@myself}
      />
      <div class="mt-3 mb-3 bg-gray-200 p-2">
        <h3><%= @match_label %></h3>
        <div class="flex flex-row h-12 gap-1">
          <%= if length(@item_matches) > 0 do %>
            <.item_match :for={item <- @item_matches} item={item} target={@myself} />
          <% else %>
            <p class="p-2 text-xs text-slate-500">None</p>
          <% end %>
        </div>
        <h3><%= @selected_label %></h3>
        <div class="flex flex-row h-12 gap-1 mt-1">
          <%= if length(@selected_items) > 0 do %>
            <.item_selected :for={item <- @selected_items} item={item} target={@myself} />
          <% else %>
            <p class="p-2 text-xs text-slate-500">None</p>
          <% end %>
        </div>
      </div>
    </div>
    """
  end

  attr :item, :map, required: true
  attr :target, :any, required: true

  def item_match(assigns) do
    ~H"""
    <div
      phx-click="item-selected"
      phx-value-selected-item-id={BookTracker.Pickable.identifier(@item)}
      phx-target={@target}
      class="bg-yellow-200 rounded-lg flex flex-row justify-center items-center p-2 text-xs hover:bg-green-200"
    >
      <%= BookTracker.Pickable.short_label(@item) %>
    </div>
    """
  end

  attr :item, :map, required: true
  attr :target, :any, required: true

  def item_selected(assigns) do
    ~H"""
    <div
      phx-click="item-removed"
      phx-value-selected-item-id={BookTracker.Pickable.identifier(@item)}
      phx-target={@target}
      class="bg-green-200 rounded-lg flex flex-row justify-center items-center p-2 text-xs hover:bg-red-200"
    >
      <%= BookTracker.Pickable.short_label(@item) %>
    </div>
    """
  end

  def handle_event("item-removed", _params = %{"selected-item-id" => item_id}, socket) do
    update(socket, :selected_items, fn current ->
      Enum.reject(current, fn selected ->
        selected.id == String.to_integer(item_id)
      end)
    end)
    |> notify_parent()
    |> then(&{:noreply, &1})
  end

  def handle_event("item-selected", %{"selected-item-id" => item_id}, socket) do
    {selected_item, other_suggested} =
      extract_item_by_id(socket.assigns.item_matches, item_id)

    socket
    |> update(:selected_items, &[selected_item | &1])
    |> assign(:item_matches, other_suggested)
    |> notify_parent()
    |> then(&{:noreply, &1})
  end

  def handle_event("update-item", params, socket) do
    item_name = extract_item_names(socket, params)  
    display_matches =
      socket.assigns.match_function.(item_name, limit: 3)
      |> Enum.reject(fn match -> match in socket.assigns.selected_items end)

    {:noreply, assign(socket, :item_matches, display_matches)}
  end

  def extract_item_by_id(item_list, id) when is_binary(id) do
    extract_item_by_id(item_list, String.to_integer(id))
  end

  def extract_item_by_id(item_list, id) do
    {item, reved} =
      Enum.reduce(item_list, {nil, []}, fn
        item = %{id: ^id}, {nil, new_list} -> {item, new_list}
        item, {found, list} -> {found, [item | list]}
      end)

    {item, Enum.reverse(reved)}
  end

  defp notify_parent(socket) do
    send(self(), {:selected_update, socket.assigns.input_identifier,socket.assigns.selected_items})
    socket
  end

  defp extract_item_names(socket, params) do
    Map.get(params, socket.assigns.input_identifier)
  end

  def get_events(), do: @events
end
