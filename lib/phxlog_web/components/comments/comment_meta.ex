defmodule PhxlogWeb.Comments.CommentMeta do
  use PhxlogWeb, :html

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
