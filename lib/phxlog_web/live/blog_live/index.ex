defmodule PhxlogWeb.BlogLive.Index do
  @moduledoc """
  LiveView for the blog administration index page.

  This module provides:
  - Paginated blog listing
  - Search functionality
  - Blog deletion
  - Real-time updates via PubSub
  - Async loading of blog data

  It is intended for admin or management use of blog posts.
  """

  use PhxlogWeb, :live_view

  import PhxlogWeb.Blogs.LoadingState
  import PhxlogWeb.Blogs.ErrorState
  import PhxlogWeb.Blogs.EmptyState

  alias Phxlog.Blogs

  @page_size "10"

  @doc """
  Initializes the LiveView.

  - Subscribes to blog PubSub events when connected
  - Initializes empty stream and UI state
  """
  def mount(_params, _session, socket) do
    if connected?(socket), do: Blogs.subscribe()

    socket =
      socket
      |> assign(:blogs_count, nil)
      |> assign(:blogs_error, nil)
      |> assign(:searching?, false)
      |> assign(:meta, nil)
      |> assign(:form, to_form(%{"q" => ""}))
      |> stream(:blogs, [])

    {:ok, socket}
  end

  @doc """
  Handles URL parameter changes.

  ## Params

    * `page` - pagination page (default: 1)
    * `q` - search query

  ## Behavior

  - Triggers async blog loading
  - Resets error/loading state
  - Updates search form state
  """
  def handle_params(params, _uri, socket) do
    page = Map.get(params, "page", "1")
    q = Map.get(params, "q", "")

    socket =
      socket
      |> assign(:page_title, "Listing Blogs")
      |> assign(:searching?, q != "")
      |> assign(:form, to_form(%{"q" => q}))
      |> assign(:blogs_count, nil)
      |> assign(:blogs_error, nil)
      |> start_async(:blogs_loader, fn ->
        Blogs.filter_blogs(%{"q" => q, "page" => page, "page_size" => @page_size})
      end)

    {:noreply, socket}
  end

  @doc """
  Handles successful async blog loading.
  """
  def handle_async(:blogs_loader, {:ok, {blogs, meta}}, socket) do
    socket =
      socket
      |> assign(:meta, meta)
      |> assign(:blogs_count, meta.count)
      |> stream(:blogs, blogs, reset: true)

    {:noreply, socket}
  end

  def handle_async(:blogs_loader, {:exit, reason}, socket) do
    socket =
      socket
      |> assign(:blogs_count, 0)
      |> assign(:blogs_error, inspect(reason))

    {:noreply, socket}
  end

  @doc """
  Handles blog deletion from UI event.

  - Deletes blog in DB
  - Updates stream optimistically
  - Adjusts local count
  """
  def handle_event("delete", %{"id" => id}, socket) do
    blog = Blogs.get_blog!(id)
    {:ok, _} = Blogs.delete_blog(blog)

    socket =
      socket
      |> stream_delete(:blogs, blog)
      |> assign(:blogs_count, max((socket.assigns.blogs_count || 1) - 1, 0))

    {:noreply, socket}
  end

  @doc """
  Handles blog deletion event from PubSub.

  - Refreshes pagination if needed
  """
  def handle_info({:blog_deleted, _blog}, socket) do
    if is_nil(socket.assigns.blogs_count) do
      {:noreply, socket}
    else
      current_page = socket.assigns.meta.page
      q = socket.assigns.form[:q].value

      page =
        if socket.assigns.blogs_count == 1 and current_page > 1,
          do: current_page - 1,
          else: current_page

      handle_params(%{"page" => to_string(page), "q" => q}, nil, socket)
    end
  end

  def handle_info({event, _blog}, socket)
      when event in [:blog_created, :blog_updated] do
    if is_nil(socket.assigns.blogs_count) do
      {:noreply, socket}
    else
      params = %{
        "page" => to_string(socket.assigns.meta.page),
        "q" => socket.assigns.form[:q].value
      }

      handle_params(params, nil, socket)
    end
  end

  def handle_info({:search, q}, socket) do
    params = if q == "", do: %{}, else: %{"q" => q}
    {:noreply, push_patch(socket, to: ~p"/admin/blogs?#{params}")}
  end
end
