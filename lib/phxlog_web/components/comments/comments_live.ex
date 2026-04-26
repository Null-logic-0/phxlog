defmodule PhxlogWeb.Comments.CommentsLive do
  @moduledoc """
  LiveComponent responsible for managing and rendering the full comments system.

  This component orchestrates:
  - Comment list rendering (via streams)
  - Comment creation and editing
  - Pagination / "load more"
  - UI states (loading, error, empty)
  - Authentication gating

  It acts as a thin UI layer and delegates actual business logic to the parent LiveView
  via message passing (`send(self(), ...)`).
  """

  use PhxlogWeb, :live_component

  import PhxlogWeb.Comments.LoadMore
  import PhxlogWeb.Comments.EmptyState
  import PhxlogWeb.Comments.ErrorState
  import PhxlogWeb.Comments.CommentList
  import PhxlogWeb.Comments.LoadingState
  import PhxlogWeb.Components.AuthPrompt
  import PhxlogWeb.Comments.CommentFormInput
  import PhxlogWeb.Comments.CommentsToggle

  @doc """
  Updates the component state based on incoming assigns.

  Supports multiple update modes:

  - `:reset_comments` → replaces entire comment stream
  - `:append_comments` → appends comments to stream
  - `:stream_insert_comment` → inserts a single comment into stream
  - `:stream_delete_comment` → removes a comment from stream
  - default → assigns values without modifying stream

  Internally uses `Phoenix.LiveView.stream/3` for efficient DOM updates.
  """
  def update(%{reset_comments: comments} = assigns, socket) do
    socket =
      socket
      |> assign(base_assigns(assigns))
      |> stream(:comments, comments, reset: true)

    {:ok, socket}
  end

  def update(%{append_comments: comments} = assigns, socket) do
    socket =
      socket
      |> assign(base_assigns(assigns))
      |> then(fn s -> Enum.reduce(comments, s, &stream_insert(&2, :comments, &1)) end)

    {:ok, socket}
  end

  def update(%{stream_insert_comment: {comment, opts}} = assigns, socket) do
    socket =
      socket
      |> assign(base_assigns(assigns))
      |> stream_insert(:comments, comment, opts)

    {:ok, socket}
  end

  def update(%{stream_delete_comment: comment} = assigns, socket) do
    socket =
      socket
      |> assign(base_assigns(assigns))
      |> stream_delete(:comments, comment)

    {:ok, socket}
  end

  def update(assigns, socket) do
    socket =
      socket
      |> maybe_init_stream()
      |> assign(base_assigns(assigns))

    {:ok, socket}
  end

  defp maybe_init_stream(socket) do
    if Map.has_key?(socket.assigns, :streams) do
      socket
    else
      stream(socket, :comments, [])
    end
  end

  defp base_assigns(assigns) do
    Map.drop(assigns, [
      :reset_comments,
      :append_comments,
      :stream_insert_comment,
      :stream_delete_comment,
      :comments
    ])
  end

  @doc """
  Renders the comments section UI.

  ## Assigns

    * `:comments_list` - raw list of comments (used for state checks)
    * `:streams.comments` - LiveView stream for rendering comments
    * `:comment_form` - form for creating comments
    * `:edit_form` - form for editing comments
    * `:editing_comment_id` - ID of comment currently being edited
    * `:current_scope` - current user scope (authentication)
    * `:comments_loading` - loading state flag
    * `:comments_error` - error state
    * `:comments_has_more` - whether more comments can be loaded
    * `:myself` - LiveComponent reference

  ## Behavior

  - Uses streams for efficient real-time updates
  - Shows form if user is authenticated
  - Shows auth prompt if user is not authenticated
  - Handles loading, error, and empty states
  - Supports inline editing of comments
  - Supports "load more" pagination

  ## Composition

  Built from smaller components:
  - `CommentFormInput`
  - `CommentList`
  - `LoadMore`
  - `EmptyState`, `ErrorState`, `LoadingState`
  - `AuthPrompt`
  """
  def render(assigns) do
    ~H"""
    <section class="w-full space-y-8">
      <.comments_toggle comments_list={@comments_list} />

      <div id="comments-panel" class="hidden space-y-6">
        <.comment_form_input
          :if={@current_scope}
          form={@comment_form}
          submit="create_comment"
          change="validate_comment"
          myself={@myself}
        />
        <.auth_prompt current_scope={@current_scope} />
        <.error_state comments_error={@comments_error} />
        <.loading_state comments_loading={@comments_loading} comments={@comments_list} />
        <.empty_state
          comments_loading={@comments_loading}
          comments={@comments_list}
          comments_error={@comments_error}
        />
        <.comment_list
          comments={@streams.comments}
          editing_comment_id={@editing_comment_id}
          current_scope={@current_scope}
          myself={@myself}
          edit_form={@edit_form}
        />
        <.load_more
          comments_has_more={@comments_has_more}
          comments_loading={@comments_loading}
          comments={@comments_list}
          myself={@myself}
        />
      </div>
    </section>
    """
  end

  @doc false

  def handle_event("validate_comment", %{"comment" => params}, socket) do
    send(self(), {:comments_live, :validate_comment, params})
    {:noreply, socket}
  end

  def handle_event("create_comment", %{"comment" => params}, socket) do
    send(self(), {:comments_live, :create_comment, params})
    {:noreply, socket}
  end

  def handle_event("edit_comment", %{"id" => id}, socket) do
    send(self(), {:comments_live, :edit_comment, id})
    {:noreply, socket}
  end

  def handle_event("cancel_edit", _params, socket) do
    send(self(), {:comments_live, :cancel_edit})
    {:noreply, socket}
  end

  def handle_event("validate_edit", %{"comment" => params, "comment_id" => id}, socket) do
    send(self(), {:comments_live, :validate_edit, params, id})
    {:noreply, socket}
  end

  def handle_event("update_comment", %{"comment" => params, "comment_id" => id}, socket) do
    send(self(), {:comments_live, :update_comment, params, id})
    {:noreply, socket}
  end

  def handle_event("delete_comment", %{"id" => id}, socket) do
    send(self(), {:comments_live, :delete_comment, id})
    {:noreply, socket}
  end

  def handle_event("load_more_comments", _params, socket) do
    send(self(), {:comments_live, :load_more_comments})
    {:noreply, socket}
  end
end
