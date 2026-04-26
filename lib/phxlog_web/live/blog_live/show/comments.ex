defmodule PhxlogWeb.BlogLive.Show.Comments do
  import Phoenix.LiveView
  import Phoenix.Component

  alias Phxlog.Blogs
  alias Phxlog.Blogs.Comment

  @comments_per_page 5

  def assign_comments(socket, blog, per_page) do
    socket
    |> assign(:editing_comment_id, nil)
    |> assign(:comment_form, comment_form(socket))
    |> assign(:edit_form, comment_form(socket))
    |> assign(:comments, [])
    |> assign(:comments_page, 1)
    |> assign(:comments_loading, true)
    |> assign(:comments_error, nil)
    |> start_async(:load_comments, fn ->
      Blogs.list_comments(blog, page: 1, per_page: per_page)
    end)
  end

  def handle_async(:load_comments, {:ok, {comments, has_more}}, socket) do
    page = socket.assigns.comments_page

    if page == 1 do
      Phoenix.LiveView.send_update(PhxlogWeb.Comments.CommentsLive,
        id: "comments",
        reset_comments: comments
      )
    else
      Phoenix.LiveView.send_update(PhxlogWeb.Comments.CommentsLive,
        id: "comments",
        append_comments: comments
      )
    end

    {:noreply,
     socket
     |> Phoenix.Component.assign(:comments_loading, false)
     |> Phoenix.Component.assign(:comments_error, nil)
     |> Phoenix.Component.assign(:comments_has_more, has_more)
     |> Phoenix.Component.assign(
       :comments,
       if(page == 1, do: comments, else: socket.assigns.comments ++ comments)
     )}
  end

  def handle_async(:load_comments, {:exit, reason}, socket) do
    {:noreply,
     socket
     |> Phoenix.Component.assign(:comments_loading, false)
     |> Phoenix.Component.assign(:comments_error, inspect(reason))}
  end

  def handle_info({:comments_live, :load_more_comments}, socket) do
    %{blog: blog, comments_page: page, comments_loading: loading, comments_has_more: has_more} =
      socket.assigns

    if loading or not has_more do
      {:noreply, socket}
    else
      next_page = page + 1

      {:noreply,
       socket
       |> Phoenix.Component.assign(:comments_page, next_page)
       |> Phoenix.Component.assign(:comments_loading, true)
       |> Phoenix.LiveView.start_async(:load_comments, fn ->
         Blogs.list_comments(blog, page: next_page, per_page: @comments_per_page)
       end)}
    end
  end

  def handle_info({:comments_live, :validate_comment, params}, socket) do
    form =
      Blogs.change_comment(socket.assigns.current_scope, %Comment{}, params)
      |> Map.put(:action, :validate)
      |> Phoenix.Component.to_form()

    {:noreply, Phoenix.Component.assign(socket, :comment_form, form)}
  end

  def handle_info({:comments_live, :create_comment, params}, socket) do
    case Blogs.create_comment(socket.assigns.current_scope, socket.assigns.blog, params) do
      {:ok, _} ->
        {:noreply, Phoenix.Component.assign(socket, :comment_form, comment_form(socket))}

      {:error, changeset} ->
        {:noreply,
         Phoenix.Component.assign(socket, :comment_form, Phoenix.Component.to_form(changeset))}
    end
  end

  def handle_info({:comments_live, :edit_comment, id}, socket) do
    id = String.to_integer(id)
    comment = Enum.find(socket.assigns.comments, &(&1.id == id))

    edit_form =
      Blogs.change_comment(socket.assigns.current_scope, comment, %{})
      |> Phoenix.Component.to_form()

    Phoenix.LiveView.send_update(PhxlogWeb.Comments.CommentsLive,
      id: "comments",
      stream_insert_comment: {comment, []}
    )

    {:noreply,
     socket
     |> Phoenix.Component.assign(:editing_comment_id, id)
     |> Phoenix.Component.assign(:edit_form, edit_form)}
  end

  def handle_info({:comments_live, :cancel_edit}, socket) do
    prev_id = socket.assigns.editing_comment_id
    comment = Enum.find(socket.assigns.comments, &(&1.id == prev_id))

    if comment do
      Phoenix.LiveView.send_update(PhxlogWeb.Comments.CommentsLive,
        id: "comments",
        stream_insert_comment: {comment, []}
      )
    end

    {:noreply, Phoenix.Component.assign(socket, :editing_comment_id, nil)}
  end

  def handle_info({:comments_live, :validate_edit, params, id}, socket) do
    comment = Enum.find(socket.assigns.comments, &(&1.id == String.to_integer(id)))

    form =
      Blogs.change_comment(socket.assigns.current_scope, comment, params)
      |> Map.put(:action, :validate)
      |> Phoenix.Component.to_form()

    {:noreply, Phoenix.Component.assign(socket, :edit_form, form)}
  end

  def handle_info({:comments_live, :update_comment, params, id}, socket) do
    comment = Enum.find(socket.assigns.comments, &(&1.id == String.to_integer(id)))

    case Blogs.update_comment(socket.assigns.current_scope, socket.assigns.blog, comment, params) do
      {:ok, _} ->
        {:noreply, Phoenix.Component.assign(socket, :editing_comment_id, nil)}

      {:error, changeset} ->
        {:noreply,
         Phoenix.Component.assign(socket, :edit_form, Phoenix.Component.to_form(changeset))}
    end
  end

  def handle_info({:comments_live, :delete_comment, id}, socket) do
    comment = Enum.find(socket.assigns.comments, &(&1.id == String.to_integer(id)))
    {:ok, _} = Blogs.delete_comment(socket.assigns.current_scope, socket.assigns.blog, comment)
    {:noreply, socket}
  end

  def handle_info({:created, comment}, socket) do
    Phoenix.LiveView.send_update(PhxlogWeb.Comments.CommentsLive,
      id: "comments",
      stream_insert_comment: {comment, [at: 0]}
    )

    {:noreply, Phoenix.Component.assign(socket, :comments, [comment | socket.assigns.comments])}
  end

  def handle_info({:updated, comment}, socket) do
    Phoenix.LiveView.send_update(PhxlogWeb.Comments.CommentsLive,
      id: "comments",
      stream_insert_comment: {comment, []}
    )

    {:noreply,
     Phoenix.Component.assign(
       socket,
       :comments,
       Enum.map(socket.assigns.comments, &if(&1.id == comment.id, do: comment, else: &1))
     )}
  end

  def handle_info({:deleted, comment}, socket) do
    Phoenix.LiveView.send_update(PhxlogWeb.Comments.CommentsLive,
      id: "comments",
      stream_delete_comment: comment
    )

    {:noreply,
     Phoenix.Component.assign(
       socket,
       :comments,
       Enum.reject(socket.assigns.comments, &(&1.id == comment.id))
     )}
  end

  defp comment_form(socket) do
    case socket.assigns[:current_scope] do
      nil -> Phoenix.Component.to_form(%{}, as: :comment)
      scope -> Blogs.change_comment(scope, %Comment{}, %{}) |> Phoenix.Component.to_form()
    end
  end
end
