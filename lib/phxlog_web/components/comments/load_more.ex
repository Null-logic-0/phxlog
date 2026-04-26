defmodule PhxlogWeb.Comments.LoadMore do
  use PhxlogWeb, :html

  attr :comments_has_more, :boolean, required: true
  attr :comments_loading, :boolean, required: true
  attr :comments, :list, required: true
  attr :myself, :any, required: true

  def load_more(assigns) do
    ~H"""
    <div
      :if={@comments_has_more || @comments_loading}
      class="flex justify-center py-4"
    >
      <div
        :if={@comments_loading && @comments != []}
        class="flex items-center gap-2 text-sm text-base-content/40"
      >
        <span class="loading loading-spinner loading-sm"></span> Loading more…
      </div>
      <button
        :if={@comments_has_more && !@comments_loading}
        phx-click="load_more_comments"
        phx-target={@myself}
        class="btn btn-sm btn-ghost text-base-content/50"
      >
        Load more comments
      </button>
    </div>
    """
  end
end
