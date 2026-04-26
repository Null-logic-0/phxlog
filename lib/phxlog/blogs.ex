defmodule Phxlog.Blogs do
  import Ecto.Query, warn: false
  alias Phxlog.Repo
  alias Pagex
  alias Phxlog.Blogs.Blog

  @pubsub Phxlog.PubSub
  @topic "blogs"

  def subscribe do
    Phoenix.PubSub.subscribe(@pubsub, @topic)
  end

  def subscribe(blog_id) do
    Phoenix.PubSub.subscribe(@pubsub, "blog:#{blog_id}")
  end

  defp broadcast(event, blog) do
    Phoenix.PubSub.broadcast(@pubsub, @topic, {event, blog})
    Phoenix.PubSub.broadcast(@pubsub, "blog:#{blog.id}", {event, blog})
    blog
  end

  def list_blogs, do: Repo.all(Blog)

  def filter_blogs(params) do
    Blog
    |> search_by(params["q"])
    |> order_by(desc: :inserted_at)
    |> Pagex.paginate(params, Repo)
  end

  defp search_by(query, q) when q in ["", nil], do: query

  defp search_by(query, q),
    do: where(query, [r], ilike(r.title, ^"%#{q}%") or ilike(r.content, ^"%#{q}%"))

  def featured_blogs(blog) do
    Blog
    |> where([r], r.id != ^blog.id)
    |> order_by(desc: :inserted_at)
    |> limit(3)
    |> Repo.all()
  end

  def get_blog!(id), do: Repo.get!(Blog, id)

  def change_blog(%Blog{} = blog, attrs \\ %{}) do
    Blog.changeset(blog, attrs)
  end

  def create_blog(attrs) do
    %Blog{}
    |> Blog.changeset(attrs)
    |> Repo.insert()
    |> tap_broadcast(:blog_created)
  end

  def update_blog(%Blog{} = blog, attrs) do
    blog
    |> Blog.changeset(attrs)
    |> Repo.update()
    |> tap_broadcast(:blog_updated)
  end

  def delete_blog(%Blog{} = blog) do
    blog
    |> Repo.delete()
    |> tap_broadcast(:blog_deleted)
  end

  defp tap_broadcast({:ok, blog}, event) do
    broadcast(event, blog)
    {:ok, blog}
  end

  defp tap_broadcast({:error, _} = err, _event), do: err

  alias Phxlog.Blogs.Comment
  alias Phxlog.Accounts.Scope

  def subscribe_comments(%Blog{} = blog) do
    Phoenix.PubSub.subscribe(Phxlog.PubSub, "blog:#{blog.id}:comments")
  end

  defp broadcast_comment(%Blog{} = blog, message) do
    Phoenix.PubSub.broadcast(Phxlog.PubSub, "blog:#{blog.id}:comments", message)
  end

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

  def get_comment!(%Blog{} = blog, id) do
    Comment
    |> where([c], c.id == ^id and c.blog_id == ^blog.id)
    |> preload(:user)
    |> Repo.one!()
  end

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

  def delete_comment(%Scope{} = scope, %Blog{} = blog, %Comment{} = comment) do
    true = comment.user_id == scope.user.id

    with {:ok, comment} <- Repo.delete(comment) do
      broadcast_comment(blog, {:deleted, comment})
      {:ok, comment}
    end
  end

  def change_comment(%Scope{} = scope, %Comment{} = comment, attrs \\ %{}) do
    Comment.changeset(comment, attrs, scope)
  end

  alias Phxlog.Blogs.Like

  alias Phxlog.Blogs.Like

  def liked_by_user?(_blog, nil), do: false

  def liked_by_user?(blog, scope) do
    Repo.exists?(from l in Like, where: l.blog_id == ^blog.id and l.user_id == ^scope.user.id)
  end

  def likes_count(blog) do
    Repo.aggregate(from(l in Like, where: l.blog_id == ^blog.id), :count)
  end

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

  defp broadcast_likes(blog) do
    count = likes_count(blog)
    Phoenix.PubSub.broadcast(Phxlog.PubSub, "blog:#{blog.id}", {:likes_updated, count})
  end
end
