defmodule PhxlogWeb.Comments.CommentList do
  @moduledoc """
  Comment list UI component.

  Responsible for rendering a list of comments with support for:
  - Stream updates (`phx-update="stream"`)
  - Inline editing
  - Conditional styling for active (editing) comment

  Composes smaller components:
  - `CommentMeta` (author, timestamp)
  - `CommentBody` (content + actions)
  - `CommentFormInput` (edit form)
  """

  use PhxlogWeb, :html
  import PhxlogWeb.Comments.CommentMeta
  import PhxlogWeb.Comments.CommentBody
  import PhxlogWeb.Comments.CommentFormInput

  @doc """
  Renders a list of comments.

  ## Assigns

    * `:comments` - list/stream of `{dom_id, comment}` tuples (required)
    * `:editing_comment_id` - ID of the comment currently being edited
    * `:current_scope` - current user scope (used for permissions)
    * `:myself` - LiveComponent reference for event targeting
    * `:edit_form` - form struct used when editing a comment

  ## Behavior

  - Uses `phx-update="stream"` for efficient real-time updates
  - Highlights the comment being edited
  - Shows edit form inline when a comment is in edit mode
  - Delegates rendering to smaller, composable components

  ## Example

      <.comment_list
        comments={@streams.comments}
        editing_comment_id={@editing_comment_id}
        current_scope={@current_scope}
        myself={@myself}
        edit_form={@edit_form}
      />
  """

  attr :comments, :list, required: true
  attr :editing_comment_id, :any, required: true
  attr :current_scope, :any, required: true
  attr :myself, :any, required: true
  attr :edit_form, :any, default: nil

  def comment_list(assigns) do
    ~H"""
    <div id="comments-stream" phx-update="stream" class="space-y-1">
      <div
        :for={{dom_id, comment} <- @comments}
        id={dom_id}
        class={[
          "group flex gap-3 px-4 py-3 rounded-box transition-colors",
          if(@editing_comment_id == comment.id,
            do: "bg-primary/5 border border-primary/20",
            else: "hover:bg-base-200"
          )
        ]}
      >
        <div class="flex-1 min-w-0">
          <.comment_meta comment={comment} />
          <.comment_body
            editing_comment_id={@editing_comment_id}
            comment={comment}
            current_scope={@current_scope}
            myself={@myself}
          />
          <.comment_form_input
            :if={@editing_comment_id == comment.id}
            form={@edit_form}
            submit="update_comment"
            change="validate_edit"
            cancel="cancel_edit"
            hidden_id={comment.id}
            myself={@myself}
          />
        </div>
      </div>
    </div>
    """
  end
end
