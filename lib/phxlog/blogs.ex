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
end
