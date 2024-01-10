defmodule BookTrackerWeb.AuthorHTML do
  use BookTrackerWeb, :html

  def show(assigns) do
    ~H"""
    <.author_full_name author={@author}/>
    <h2 class="font-semibold mb-3"> Biography </h2>
    <div>
      <%= raw(@author.bio_notes) %>
    </div>
    """
  end

  def not_found(assigns) do
    ~H"""
      <h1 class="text-lg font-semibold"> Author With ID <%= @author_id %> Not Found </h1>
    """
  end

  attr :author, :map, required: true

  def author_full_name(assigns) do
    ~H"""
    <h1 class="text-lg font-semibold mb-5">
      <%= String.capitalize(@author.first_name) %> <%= String.capitalize(@author.last_name) %>
    </h1>
    """
  end
end
