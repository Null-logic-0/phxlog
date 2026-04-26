defmodule PhxlogWeb.Comments.LoadingState do
  @moduledoc """
  Loading state component for the comments section.

  Displays a skeleton UI while comments are being loaded for the first time.
  """

  use PhxlogWeb, :html

  @doc """
  Renders a loading skeleton for comments.

  ## Assigns

    * `:comments_loading` - loading state flag
    * `:comments` - current list of comments

  ## Behavior

  - Only renders when:
    - `comments_loading` is true
    - `comments` is empty (initial load)
  - Displays multiple placeholder rows with animated pulse effect

  ## Example

      <.loading_state
        comments_loading={@comments_loading}
        comments={@comments_list}
      />
  """

  attr :comments_loading, :boolean, default: false
  attr :comments, :list, default: []

  def loading_state(assigns) do
    ~H"""
    <div :if={@comments_loading && @comments == []} class="space-y-3">
      <div :for={_ <- 1..5} class="flex gap-3 px-4 py-3 animate-pulse">
        <div class="w-9 h-9 rounded-full bg-base-300 flex-shrink-0"></div>
        <div class="flex-1 space-y-2 pt-1">
          <div class="h-3 bg-base-300 rounded w-1/4"></div>
          <div class="h-3 bg-base-300 rounded w-3/4"></div>
          <div class="h-3 bg-base-300 rounded w-1/2"></div>
        </div>
      </div>
    </div>
    """
  end
end
