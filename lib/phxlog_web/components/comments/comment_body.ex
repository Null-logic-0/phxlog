defmodule PhxlogWeb.Comments.CommentBody do
  use PhxlogWeb, :html

  attr :comment, :any, required: true
  attr :editing_comment_id, :any, required: true
  attr :current_scope, :any, required: true
  attr :myself, :any, required: true

  def comment_body(assigns) do
    ~H"""
    <div :if={@editing_comment_id != @comment.id}>
      <p class="text-sm text-base-content/70 leading-relaxed">{@comment.content}</p>
      <div
        :if={@current_scope && @current_scope.user.id == @comment.user_id}
        class="flex gap-3 mt-2 opacity-0 group-hover:opacity-100 transition-opacity"
      >
        <button
          phx-click="edit_comment"
          phx-value-id={@comment.id}
          phx-target={@myself}
          class="text-xs cursor-pointer text-base-content/40 hover:text-primary transition-colors font-medium"
        >
          Edit
        </button>
        <button
          phx-click="delete_comment"
          phx-value-id={@comment.id}
          phx-target={@myself}
          data-confirm="Delete this comment?"
          class="text-xs cursor-pointer text-base-content/40 hover:text-error transition-colors font-medium"
        >
          Delete
        </button>
      </div>
    </div>
    """
  end
end
