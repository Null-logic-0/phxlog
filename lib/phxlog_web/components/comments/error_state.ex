defmodule PhxlogWeb.Comments.ErrorState do
  use PhxlogWeb, :html

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
