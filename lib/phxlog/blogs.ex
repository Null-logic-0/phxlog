defmodule Phxlog.Blogs do
  @moduledoc """
  The Blogs context.

  This module encapsulates all blog-related business logic including:

  - Blog CRUD operations
  - Search and pagination
  - Real-time updates via PubSub
  - Comment management
  - Like system

  It serves as the boundary between controllers/live views and the data layer,
  ensuring consistent data access and event broadcasting across the system.
  """

  import Ecto.Query, warn: false
  alias Phxlog.Repo
  alias Pagex
  alias Phxlog.Blogs.Blog

  @pubsub Phxlog.PubSub
  @topic "blogs"

  @doc """
  Subscribes the current process to all blog events.
  """
  def subscribe do
    Phoenix.PubSub.subscribe(@pubsub, @topic)
  end

  @doc """
  Subscribes to events for a specific blog.
  """
  def subscribe(blog_id) do
    Phoenix.PubSub.subscribe(@pubsub, "blog:#{blog_id}")
  end

  @doc false
  defp broadcast(event, blog) do
    Phoenix.PubSub.broadcast(@pubsub, @topic, {event, blog})
    Phoenix.PubSub.broadcast(@pubsub, "blog:#{blog.id}", {event, blog})
    blog
  end

  @doc """
  Returns all blogs.
  """
  def list_blogs, do: Repo.all(Blog)

  @doc """
  Returns paginated blogs filtered by search params.

  Supports:
  - `"q"`: search query (matches title and content)
  - pagination params handled by Pagex
  """
  def filter_blogs(params) do
    Blog
    |> search_by(params["q"])
    |> order_by(desc: :inserted_at)
    |> Pagex.paginate(params, Repo)
  end

  @doc false
  defp search_by(query, q) when q in ["", nil], do: query

  @doc false
  defp search_by(query, q),
    do: where(query, [r], ilike(r.title, ^"%#{q}%") or ilike(r.content, ^"%#{q}%"))

  @doc """
  Returns 3 latest blogs excluding the given one.

  Useful for "related posts" or "featured" sections.
  """
  def featured_blogs(blog) do
    Blog
    |> where([r], r.id != ^blog.id)
    |> order_by(desc: :inserted_at)
    |> limit(3)
    |> Repo.all()
  end

  @doc """
  Gets a single blog by ID.

  Raises `Ecto.NoResultsError` if not found.
  """
  def get_blog!(id), do: Repo.get!(Blog, id)

  @doc """
  Returns a changeset for tracking blog changes.
  """
  def change_blog(%Blog{} = blog, attrs \\ %{}) do
    Blog.changeset(blog, attrs)
  end

  @doc """
  Creates a blog and broadcasts a `:blog_created` event on success.
  """
  def create_blog(attrs) do
    %Blog{}
    |> Blog.changeset(attrs)
    |> Repo.insert()
    |> tap_broadcast(:blog_created)
  end

  @doc """
  Updates a blog and broadcasts a `:blog_updated` event on success.
  """
  def update_blog(%Blog{} = blog, attrs) do
    blog
    |> Blog.changeset(attrs)
    |> Repo.update()
    |> tap_broadcast(:blog_updated)
  end

  @doc """
  Deletes a blog and broadcasts a `:blog_deleted` event on success.
  """
  def delete_blog(%Blog{} = blog) do
    blog
    |> Repo.delete()
    |> tap_broadcast(:blog_deleted)
  end

  @doc false
  defp tap_broadcast({:ok, blog}, event) do
    broadcast(event, blog)
    {:ok, blog}
  end

  defp tap_broadcast({:error, _} = err, _event), do: err

  alias Phxlog.Blogs.Comment
  alias Phxlog.Accounts.Scope

  @doc """
  Subscribes to comment events for a blog.
  """
  def subscribe_comments(%Blog{} = blog) do
    Phoenix.PubSub.subscribe(Phxlog.PubSub, "blog:#{blog.id}:comments")
  end

  @doc false
  defp broadcast_comment(%Blog{} = blog, message) do
    Phoenix.PubSub.broadcast(Phxlog.PubSub, "blog:#{blog.id}:comments", message)
  end

  @doc """
  Lists comments for a blog with manual pagination.

  Returns `{comments, has_more}`.
  """
  def list_comments(%Blog{} = blog, opts \\ []) do
    page = Keyword.get(opts, :page, 1)
    per_page = Keyword.get(opts, :per_page, 10)
    offset = (page - 1) * per_page

    comments =
      Comment
      |> where([c], c.blog_id == ^blog.id)
      |> order_by(desc: :inserted_at)
      |> limit(^(per_page + 1))
      |> offset(^offset)
      |> preload(:user)
      |> Repo.all()

    has_more = length(comments) > per_page
    {Enum.take(comments, per_page), has_more}
  end

  @doc """
  Gets a single comment belonging to a blog.

  Raises if not found.
  """
  def get_comment!(%Blog{} = blog, id) do
    Comment
    |> where([c], c.id == ^id and c.blog_id == ^blog.id)
    |> preload(:user)
    |> Repo.one!()
  end

  @doc """
  Creates a comment and broadcasts a `{:created, comment}` event.
  """
  def create_comment(%Scope{} = scope, %Blog{} = blog, attrs) do
    with {:ok, comment} <-
           %Comment{blog_id: blog.id}
           |> Comment.changeset(attrs, scope)
           |> Repo.insert() do
      comment = Repo.preload(comment, :user)
      broadcast_comment(blog, {:created, comment})
      {:ok, comment}
    end
  end

  @doc """
  Updates a comment (only by its author) and broadcasts `{:updated, comment}`.
  """
  def update_comment(%Scope{} = scope, %Blog{} = blog, %Comment{} = comment, attrs) do
    true = comment.user_id == scope.user.id

    with {:ok, comment} <-
           comment
           |> Comment.changeset(attrs, scope)
           |> Repo.update() do
      comment = Repo.preload(comment, :user)
      broadcast_comment(blog, {:updated, comment})
      {:ok, comment}
    end
  end

  @doc """
  Deletes a comment (only by its author) and broadcasts `{:deleted, comment}`.
  """
  def delete_comment(%Scope{} = scope, %Blog{} = blog, %Comment{} = comment) do
    true = comment.user_id == scope.user.id

    with {:ok, comment} <- Repo.delete(comment) do
      broadcast_comment(blog, {:deleted, comment})
      {:ok, comment}
    end
  end

  @doc """
  Returns a changeset for comment changes.
  """
  def change_comment(%Scope{} = scope, %Comment{} = comment, attrs \\ %{}) do
    Comment.changeset(comment, attrs, scope)
  end

  alias Phxlog.Blogs.Like

  @doc """
  Checks if a blog is liked by the given user.
  """
  def liked_by_user?(_blog, nil), do: false

  def liked_by_user?(blog, scope) do
    Repo.exists?(from l in Like, where: l.blog_id == ^blog.id and l.user_id == ^scope.user.id)
  end

  @doc """
  Returns the total number of likes for a blog.
  """
  def likes_count(blog) do
    Repo.aggregate(from(l in Like, where: l.blog_id == ^blog.id), :count)
  end

  @doc """
  Toggles like for a blog:

  - Creates like if not exists
  - Deletes like if exists

  Broadcasts updated like count.
  """
  def toggle_like(scope, blog) do
    case Repo.get_by(Like, blog_id: blog.id, user_id: scope.user.id) do
      nil ->
        %Like{}
        |> Ecto.Changeset.change(%{blog_id: blog.id, user_id: scope.user.id})
        |> Repo.insert()
        |> case do
          {:ok, _} -> broadcast_likes(blog)
          {:error, _} -> :error
        end

      like ->
        {:ok, _} = Repo.delete(like)
        broadcast_likes(blog)
    end
  end

  @doc false
  defp broadcast_likes(blog) do
    count = likes_count(blog)
    Phoenix.PubSub.broadcast(Phxlog.PubSub, "blog:#{blog.id}", {:likes_updated, count})
  end
end
