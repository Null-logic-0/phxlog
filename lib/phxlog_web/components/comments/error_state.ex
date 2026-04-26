defmodule PhxlogWeb.Comments.ErrorState do
  @moduledoc """
  Error state component for the comments section.

  Displays an error message when comments fail to load
  and provides a retry action.
  """

  use PhxlogWeb, :html

  @doc """
  Renders an error state for comments.

  ## Assigns

    * `:comments_error` - error value indicating failure (truthy when error exists)

  ## Behavior

  - Only renders when `comments_error` is present
  - Shows a retry button to trigger comment reload

  ## Events

    * `"load_more_comments"` - retry loading comments

  ## Example

      <.error_state comments_error={@comments_error} />
  """

  attr :comments_error, :any, default: nil

  def error_state(assigns) do
    ~H"""
    <div
      :if={@comments_error}
      class="rounded-box border border-error/20 bg-error/5 p-4 flex gap-3"
    >
      <.icon name="hero-exclamation-triangle" class="size-5 text-error flex-shrink-0 mt-0.5" />
      <div>
        <p class="text-sm font-medium text-error">Failed to load comments</p>
        <button
          phx-click="load_more_comments"
          class="text-xs text-error/70 hover:text-error underline mt-1"
        >
          Try again
        </button>
      </div>
    </div>
    """
  end
end
