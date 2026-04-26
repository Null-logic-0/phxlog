defmodule PhxlogWeb.BlogLive.Show do
  @moduledoc """
  LiveView responsible for displaying a single blog post.

  This module orchestrates:
  - Blog fetching and real-time updates
  - Comments system (delegated to Comments sub-module)
  - Likes system (delegated to Likes sub-module)
  - Featured blogs sidebar
  - PubSub subscriptions for live updates

  This is the main blog detail page.
  """

  use PhxlogWeb, :live_view

  alias Phxlog.Blogs
  import PhxlogWeb.Blogs.FeaturedBlogs
  import PhxlogWeb.BlogLive.Show.Comments
  import PhxlogWeb.BlogLive.Show.Likes

  on_mount {PhxlogWeb.UserAuth, :mount_current_scope}

  @comments_per_page 5

  @doc """
  Initializes base LiveView state for comments and UI flags.
  """
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:comments, [])
     |> assign(:comments_page, 1)
     |> assign(:comments_has_more, false)
     |> assign(:comments_loading, false)
     |> assign(:comments_error, nil)}
  end

  @doc """
  Loads the blog post and subscribes to PubSub topics.

  Also initializes:
  - likes state
  - comments pagination
  - featured blogs async loading
  """
  def handle_params(%{"id" => id}, _uri, socket) do
    blog = Blogs.get_blog!(id)

    if connected?(socket), do: Blogs.subscribe(id)
    if connected?(socket), do: Blogs.subscribe_comments(blog)

    socket =
      socket
      |> assign(:page_title, blog.title)
      |> assign(:blog, blog)
      |> assign_likes(blog)
      |> assign_comments(blog, @comments_per_page)
      |> assign_async(:featured_blogs, fn ->
        {:ok, %{featured_blogs: Blogs.featured_blogs(blog)}}
      end)

    {:noreply, socket}
  end

  @doc false
  def handle_async(:load_comments, result, socket),
    do: PhxlogWeb.BlogLive.Show.Comments.handle_async(:load_comments, result, socket)

  @doc false
  def handle_info({:comments_live, _, _} = msg, socket),
    do: PhxlogWeb.BlogLive.Show.Comments.handle_info(msg, socket)

  @doc false
  def handle_info({:comments_live, _, _, _} = msg, socket),
    do: PhxlogWeb.BlogLive.Show.Comments.handle_info(msg, socket)

  @doc false
  def handle_info({:comments_live, :load_more_comments} = msg, socket),
    do: PhxlogWeb.BlogLive.Show.Comments.handle_info(msg, socket)

  @doc false
  def handle_info({event, _} = msg, socket) when event in [:created, :updated, :deleted],
    do: PhxlogWeb.BlogLive.Show.Comments.handle_info(msg, socket)

  @doc false
  def handle_info({event, _} = msg, socket) when event in [:likes_updated, :like_live],
    do: PhxlogWeb.BlogLive.Show.Likes.handle_info(msg, socket)

  @doc false
  def handle_info({:like_live, _} = msg, socket),
    do: PhxlogWeb.BlogLive.Show.Likes.handle_info(msg, socket)

  @doc """
  Updates blog when it changes via PubSub.
  """
  def handle_info({:blog_updated, blog}, socket) do
    {:noreply, assign(socket, :blog, blog)}
  end

  def handle_info({:blog_deleted, _blog}, socket) do
    {:noreply,
     socket
     |> put_flash(:info, "This blog has been deleted.")
     |> push_navigate(to: ~p"/")}
  end
end
