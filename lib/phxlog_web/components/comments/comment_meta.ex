defmodule PhxlogWeb.Comments.CommentMeta do
  @moduledoc """
  Comment metadata UI component.

  Displays basic information about a comment:
  - Author name
  - Creation date

  Typically used as the header section of a comment item.
  """

  use PhxlogWeb, :html

  @doc """
  Renders metadata for a comment.

  ## Assigns

    * `:comment` - comment struct with preloaded user (required)

  ## Requirements

  - `comment.user` must be preloaded
  - `comment.user.full_name` is used for display
  - `comment.inserted_at` is formatted as a readable date

  ## Example

      <.comment_meta comment={@comment} />
  """

  attr :comment, :any, required: true

  def comment_meta(assigns) do
    ~H"""
    <div class="flex items-baseline justify-between gap-2 mb-1">
      <span class="text-sm font-semibold text-base-content">{@comment.user.full_name}</span>
      <span class="text-xs text-base-content/40 flex-shrink-0">
        {Calendar.strftime(@comment.inserted_at, "%b %d, %Y")}
      </span>
    </div>
    """
  end
end
