defmodule PhxlogWeb.Comments.CommentBody do
  @moduledoc """
  Comment body UI component.

  Responsible for rendering:
  - Comment content
  - Edit/Delete actions (for comment owner only)
  - Conditional UI for editing state

  This component is used inside comment lists and supports inline editing.
  """

  use PhxlogWeb, :html

  @doc """
  Renders the body of a comment.

  ## Assigns

    * `:comment` - comment struct (required)
    * `:editing_comment_id` - currently edited comment ID
    * `:current_scope` - current user scope (used for permission checks)
    * `:myself` - LiveComponent reference for event targeting

  ## Behavior

  - Shows comment content when not editing
  - Shows edit/delete actions only for comment owner
  - Hides content when comment is in editing state

  ## Events

    * `"edit_comment"` - triggers edit mode for comment
    * `"delete_comment"` - deletes comment (with confirmation)

  ## Example

      <.comment_body
        comment={@comment}
        editing_comment_id={@editing_comment_id}
        current_scope={@current_scope}
        myself={@myself}
      />
  """

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
