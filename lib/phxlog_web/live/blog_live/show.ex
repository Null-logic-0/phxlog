defmodule PhxlogWeb.BlogLive.Show do
  use PhxlogWeb, :live_view

  alias Phxlog.Blogs
  import PhxlogWeb.Blogs.FeaturedBlogs

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        <h1 class="text-3xl font-bold">{@blog.title}</h1>

        <:actions>
          <.button navigate={~p"/"}>
            <.icon name="hero-arrow-left" />
          </.button>
        </:actions>
      </.header>

      <div class="rounded-xl my-6 overflow-hidden shadow-lg">
        <img
          src={@blog.image_path}
          alt={@blog.title}
          class="w-full h-80 object-cover"
        />
      </div>

      <div class="prose max-w-none">
        <p>
          {@blog.content}
        </p>
      </div>

      <hr class="my-12" />
      <.featured_blogs blogs={@featured_blogs} />
    </Layouts.app>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_params(%{"id" => id}, _uri, socket) do
    blog = Blogs.get_blog!(id)

    if connected?(socket), do: Blogs.subscribe(id)

    socket =
      socket
      |> assign(:page_title, "#{blog.title}")
      |> assign(:blog, blog)
      |> assign_async(:featured_blogs, fn ->
        {:ok, %{featured_blogs: Blogs.featured_blogs(blog)}}
      end)

    {:noreply, socket}
  end

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
