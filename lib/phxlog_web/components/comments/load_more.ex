defmodule PhxlogWeb.Comments.LoadMore do
  @moduledoc """
  Load-more component for paginated comments.

  Handles:
  - Triggering pagination requests
  - Displaying loading indicators
  - Conditionally rendering "Load more" button

  Designed to work with LiveView event-driven pagination.
  """

  use PhxlogWeb, :html

  @doc """
  Renders pagination controls for comments.

  ## Assigns

    * `:comments_has_more` - whether more comments are available (required)
    * `:comments_loading` - loading state flag (required)
    * `:comments` - current list of comments (required)
    * `:myself` - LiveComponent reference for event targeting (required)

  ## Behavior

  - Shows spinner when loading additional comments (and list is not empty)
  - Shows "Load more comments" button when more data is available
  - Hidden when no more comments and not loading

  ## Events

    * `"load_more_comments"` - triggers loading next page

  ## Example

      <.load_more
        comments_has_more={@comments_has_more}
        comments_loading={@comments_loading}
        comments={@comments_list}
        myself={@myself}
      />
  """

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
