defmodule BookTrackerWeb.LiveComponents.MatchAndSelect do
  use BookTrackerWeb, :live_component 

  @moduledoc """
  # Match and Select

  Manages a text box input for picking related items in a database.  The user is given matches for the string they have entered into the form text input and can click one of those matches to "attach" it to the current object.  Selected items are sent back to the parent liveview using the input_identifier property (see properties below).

  ## Messages

  Parent liveview must handle messages in the form: {:selected_update, input_identifier, selected_value} where input_identifier is specified by the parent and selected_value is a list of items selected by the user.

  ## Properties 
        - reset: a property that will change when the form handled by this component should be reset.  The value of this prop does not matter, it just acts as a signal to reset the form. 
        - match_function: a function for retrieving a matches that takes a string as the first argument and a keyword list of options.
        - input_label: the label for the text input that will be rendered by this component.
        - input_identifier: a string that identifies the form rendered by this components and is also used to label messages sent to the parent liveview.
        - match_label: a string to label the matches retrieved by the match function.
        - selected_label: a string to label the items selected by the user.
        - form_field: the corresponding form field that is being handled by match and select.  This is required for form errors to be displayed.
  """

  @events %{
    "item-selected" => "item has been selected by the user.",
    "update-item" => "item text field has changed",
    "item-removed" => "selected item has been clicked, indicated removal"
  }

  def update(assigns, socket) do
    socket
    |> assign(:item_input, "")
    |> assign(:item_matches, [])
    |> assign(:selected_items, [])
    |> assign(assigns)
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
        field={@form_field}
        autocomplete="off"
        phx-change="update-item"
        phx-debounce="500"
        phx-target={@myself}
      />
      <div class="mt-3 mb-3 bg-neutral p-2">
        <h3 class="mb-1"><%= @match_label %></h3>
        <div class="flex flex-row h-12 gap-1 text-primary-content">
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
      class="badge badge-info badge-lg hover:badge-success"
    >
      <div class="flex flex-row gap-1 align-middle">
      <.icon name="hero-plus-circle" class="mt-0.5 text-center"/> 
      <%= BookTracker.Pickable.short_label(@item) %>
      </div>
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
      class="badge badge-success badge-lg hover:badge-error"
    >
      <div class="flex flex-row gap-1 align-middle">
      <.icon name="hero-x-circle" class="mt-0.5 text-center"/> 
      <%= BookTracker.Pickable.short_label(@item) %>
      </div>
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
    send(
      self(),
      {:selected_update, socket.assigns.input_identifier, socket.assigns.selected_items}
    )

    socket
  end

  defp extract_item_names(socket, params) do
    Map.get(params, socket.assigns.input_identifier)
  end

  def get_events(), do: @events
end
