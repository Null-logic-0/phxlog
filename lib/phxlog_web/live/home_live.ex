defmodule PhxlogWeb.HomeLive do
  @moduledoc """
  LiveView responsible for rendering the home page blog feed.

  This module handles:
  - Blog listing with pagination
  - Search (query-based filtering)
  - Real-time updates via PubSub (create/update/delete)
  - Async loading of blog data
  - Stream-based rendering for performance

  It acts as the main entry point for browsing blogs.
  """

  use PhxlogWeb, :live_view

  import PhxlogWeb.Blogs.BlogGrid

  alias Phxlog.Blogs

  @page_size "9"

  on_mount {PhxlogWeb.UserAuth, :mount_current_scope}

  @doc """
  Initializes the LiveView state.

  - Subscribes to blog PubSub events when connected
  - Initializes empty stream and default assigns
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
  Handles URL parameter changes (pagination + search).

  ## Params

    * `page` - current pagination page (default: 1)
    * `q` - search query string

  ## Behavior

  - Triggers async blog loading
  - Updates form state
  - Resets error/loading states
  """

  def handle_params(params, _uri, socket) do
    page = Map.get(params, "page", "1")
    q = Map.get(params, "q", "")

    socket =
      socket
      |> assign(page_title: "All Blogs")
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

  Updates:
  - stream of blogs
  - pagination metadata
  - total count
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
  Handles blog deletion events from PubSub.
  Handles blog creation and updates via PubSub.
  Handles search input events from child components.

  - Adjusts pagination if current page becomes invalid.
  - Refreshes current page data to reflect changes.
  - Pushes URL patch to trigger `handle_params/3`.
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
    {:noreply, push_patch(socket, to: ~p"/?#{params}")}
  end
end
