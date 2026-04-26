defmodule PhxlogWeb.Comments.EmptyState do
  use PhxlogWeb, :html

  def empty_state(assigns) do
    ~H"""
    <div :if={!@comments_loading && @comments == [] && !@comments_error} class="text-center py-12">
      <.icon name="hero-chat-bubble-left-right" class="size-10 text-base-content/20 mx-auto mb-3" />
      <p class="text-sm text-base-content/40">No comments yet. Be the first!</p>
    </div>
    """
  end
end
