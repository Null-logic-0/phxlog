defmodule PhxlogWeb.Comments.CommentList do
  use PhxlogWeb, :html
  import PhxlogWeb.Comments.CommentMeta
  import PhxlogWeb.Comments.CommentBody
  import PhxlogWeb.Comments.CommentFormInput

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
