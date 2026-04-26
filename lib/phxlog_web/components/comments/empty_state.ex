defmodule PhxlogWeb.Comments.EmptyState do
  @moduledoc """
  Empty state component for the comments section.

  Displays a friendly message when:
  - Comments are not loading
  - No comments exist
  - No error is present
  """

  use PhxlogWeb, :html

  @doc """
  Renders the empty state for comments.

  ## Assigns

    * `:comments` - list of comments
    * `:comments_loading` - loading state flag
    * `:comments_error` - error state

  ## Behavior

  - Only renders when:
    - `comments_loading` is false
    - `comments` is empty
    - `comments_error` is not present

  ## Example

      <.empty_state
        comments={@comments_list}
        comments_loading={@comments_loading}
        comments_error={@comments_error}
      />
  """

  attr :comments, :list, required: true
  attr :comments_loading, :boolean, default: false
  attr :comments_error, :any, default: nil

  def empty_state(assigns) do
    ~H"""
    <div :if={!@comments_loading && @comments == [] && !@comments_error} class="text-center py-12">
      <.icon name="hero-chat-bubble-left-right" class="size-10 text-base-content/20 mx-auto mb-3" />
      <p class="text-sm text-base-content/40">No comments yet. Be the first!</p>
    </div>
    """
  end
end
