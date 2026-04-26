defmodule PhxlogWeb.BlogLive.Show do
  use PhxlogWeb, :live_view

  alias Phxlog.Blogs
  alias Phxlog.Blogs.Comment
  import PhxlogWeb.Blogs.FeaturedBlogs

  on_mount {PhxlogWeb.UserAuth, :mount_current_scope}

  @comments_per_page 5

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:comments, [])
     |> assign(:comments_page, 1)
     |> assign(:comments_has_more, false)
     |> assign(:comments_loading, false)
     |> assign(:comments_error, nil)}
  end

  def handle_params(%{"id" => id}, _uri, socket) do
    blog = Blogs.get_blog!(id)

    if connected?(socket), do: Blogs.subscribe(id)
    if connected?(socket), do: Blogs.subscribe_comments(blog)

    socket =
      socket
      |> assign(:page_title, blog.title)
      |> assign(:blog, blog)
      |> assign(:editing_comment_id, nil)
      |> assign(:comment_form, comment_form(socket))
      |> assign(:edit_form, comment_form(socket))
      |> assign(:comments, [])
      |> assign(:comments_page, 1)
      |> assign(:comments_loading, true)
      |> assign(:comments_error, nil)
      |> assign(:likes_count, Blogs.likes_count(blog))
      |> assign(:liked, Blogs.liked_by_user?(blog, socket.assigns[:current_scope]))
      |> assign_async(:featured_blogs, fn ->
        {:ok, %{featured_blogs: Blogs.featured_blogs(blog)}}
      end)
      |> start_async(:load_comments, fn ->
        Blogs.list_comments(blog, page: 1, per_page: @comments_per_page)
      end)

    {:noreply, socket}
  end

  # ── async ────────────────────────────────────────────────────────────────────

  def handle_async(:load_comments, {:ok, {comments, has_more}}, socket) do
    page = socket.assigns.comments_page

    if page == 1 do
      send_update(PhxlogWeb.Comments.CommentsLive,
        id: "comments",
        reset_comments: comments
      )
    else
      send_update(PhxlogWeb.Comments.CommentsLive,
        id: "comments",
        append_comments: comments
      )
    end

    socket =
      socket
      |> assign(:comments_loading, false)
      |> assign(:comments_error, nil)
      |> assign(:comments_has_more, has_more)
      |> assign(:comments, if(page == 1, do: comments, else: socket.assigns.comments ++ comments))

    {:noreply, socket}
  end

  def handle_async(:load_comments, {:exit, reason}, socket) do
    {:noreply,
     socket
     |> assign(:comments_loading, false)
     |> assign(:comments_error, inspect(reason))}
  end

  # ── delegated events from CommentsLive ───────────────────────────────────────

  def handle_info({:comments_live, :load_more_comments}, socket) do
    %{blog: blog, comments_page: page, comments_loading: loading, comments_has_more: has_more} =
      socket.assigns

    if loading or not has_more do
      {:noreply, socket}
    else
      next_page = page + 1

      socket =
        socket
        |> assign(:comments_page, next_page)
        |> assign(:comments_loading, true)
        |> start_async(:load_comments, fn ->
          Blogs.list_comments(blog, page: next_page, per_page: @comments_per_page)
        end)

      {:noreply, socket}
    end
  end

  def handle_info({:comments_live, :validate_comment, params}, socket) do
    form =
      Blogs.change_comment(socket.assigns.current_scope, %Comment{}, params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, :comment_form, form)}
  end

  def handle_info({:comments_live, :create_comment, params}, socket) do
    case Blogs.create_comment(socket.assigns.current_scope, socket.assigns.blog, params) do
      {:ok, _} -> {:noreply, assign(socket, :comment_form, comment_form(socket))}
      {:error, changeset} -> {:noreply, assign(socket, :comment_form, to_form(changeset))}
    end
  end

  def handle_info({:comments_live, :edit_comment, id}, socket) do
    id = String.to_integer(id)
    comment = Enum.find(socket.assigns.comments, &(&1.id == id))
    edit_form = Blogs.change_comment(socket.assigns.current_scope, comment, %{}) |> to_form()

    send_update(PhxlogWeb.Comments.CommentsLive,
      id: "comments",
      stream_insert_comment: {comment, []}
    )

    {:noreply,
     socket
     |> assign(:editing_comment_id, id)
     |> assign(:edit_form, edit_form)}
  end

  def handle_info({:comments_live, :cancel_edit}, socket) do
    prev_id = socket.assigns.editing_comment_id
    comment = Enum.find(socket.assigns.comments, &(&1.id == prev_id))

    if comment do
      send_update(PhxlogWeb.Comments.CommentsLive,
        id: "comments",
        stream_insert_comment: {comment, []}
      )
    end

    {:noreply, assign(socket, :editing_comment_id, nil)}
  end

  def handle_info({:comments_live, :validate_edit, params, id}, socket) do
    comment = Enum.find(socket.assigns.comments, &(&1.id == String.to_integer(id)))

    form =
      Blogs.change_comment(socket.assigns.current_scope, comment, params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, :edit_form, form)}
  end

  def handle_info({:comments_live, :update_comment, params, id}, socket) do
    comment = Enum.find(socket.assigns.comments, &(&1.id == String.to_integer(id)))

    case Blogs.update_comment(socket.assigns.current_scope, socket.assigns.blog, comment, params) do
      {:ok, _} -> {:noreply, assign(socket, :editing_comment_id, nil)}
      {:error, changeset} -> {:noreply, assign(socket, :edit_form, to_form(changeset))}
    end
  end

  def handle_info({:comments_live, :delete_comment, id}, socket) do
    comment = Enum.find(socket.assigns.comments, &(&1.id == String.to_integer(id)))
    {:ok, _} = Blogs.delete_comment(socket.assigns.current_scope, socket.assigns.blog, comment)
    {:noreply, socket}
  end

  # ── PubSub ───────────────────────────────────────────────────────────────────

  def handle_info({:blog_updated, blog}, socket) do
    {:noreply, assign(socket, :blog, blog)}
  end

  def handle_info({:blog_deleted, _blog}, socket) do
    {:noreply,
     socket
     |> put_flash(:info, "This blog has been deleted.")
     |> push_navigate(to: ~p"/")}
  end

  def handle_info({:created, comment}, socket) do
    send_update(PhxlogWeb.Comments.CommentsLive,
      id: "comments",
      stream_insert_comment: {comment, [at: 0]}
    )

    {:noreply, assign(socket, :comments, [comment | socket.assigns.comments])}
  end

  def handle_info({:updated, comment}, socket) do
    send_update(PhxlogWeb.Comments.CommentsLive,
      id: "comments",
      stream_insert_comment: {comment, []}
    )

    {:noreply,
     assign(
       socket,
       :comments,
       Enum.map(socket.assigns.comments, &if(&1.id == comment.id, do: comment, else: &1))
     )}
  end

  def handle_info({:deleted, comment}, socket) do
    send_update(PhxlogWeb.Comments.CommentsLive,
      id: "comments",
      stream_delete_comment: comment
    )

    {:noreply,
     assign(socket, :comments, Enum.reject(socket.assigns.comments, &(&1.id == comment.id)))}
  end

  def handle_info({:likes_updated, count}, socket) do
    send_update(PhxlogWeb.Components.LikeLive,
      id: "like-button",
      likes_count: count,
      liked: Blogs.liked_by_user?(socket.assigns.blog, socket.assigns[:current_scope])
    )

    {:noreply, socket}
  end

  def handle_info({:like_live, :not_logged_in}, socket) do
    {:noreply, put_flash(socket, :error, "You must be logged in to like.")}
  end

  def handle_info({:like_live, :error}, socket) do
    {:noreply, put_flash(socket, :error, "Something went wrong.")}
  end

  defp comment_form(socket) do
    case socket.assigns[:current_scope] do
      nil -> to_form(%{}, as: :comment)
      scope -> Blogs.change_comment(scope, %Comment{}, %{}) |> to_form()
    end
  end
end
