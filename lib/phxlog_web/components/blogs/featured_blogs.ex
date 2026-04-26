defmodule PhxlogWeb.Blogs.FeaturedBlogs do
  @moduledoc """
  Featured blogs section component.

  Displays a curated list of featured blogs with full async state handling:

  - Loading state
  - Error state
  - Empty state
  - Grid of featured blog cards

  Built on top of `AsyncResult` for LiveView-friendly async rendering.
  """
  use PhxlogWeb, :html

  import PhxlogWeb.Blogs.BlogCard
  import PhxlogWeb.Blogs.LoadingState
  import PhxlogWeb.Blogs.ErrorState
  import PhxlogWeb.Blogs.EmptyState

  @doc """
  Renders the featured blogs section.

  ## Assigns

    * `:blogs` - async result containing a list of blogs

  ## Behavior

  Uses `<.async_result>` to handle:

    - Loading state → shows `LoadingState`
    - Failure state → shows `ErrorState`
    - Empty result → shows `EmptyState`
    - Success → renders blog grid

  ## Example

      <.featured_blogs blogs={@featured_blogs} />
  """
  attr :blogs, :any, required: true

  def featured_blogs(assigns) do
    ~H"""
    <section class="w-full space-y-6">
      <.section_header />

      <.async_result :let={result} assign={@blogs}>
        <:loading>
          <.loading_state />
        </:loading>

        <:failed :let={{:error, reason}}>
          <.error_state reason={reason} />
        </:failed>

        <.empty_state
          :if={result == []}
          label="No featured blogs yet"
          sublabel="Check back soon for new posts"
        />

        <div :if={result != []} class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
          <article
            :for={blog <- result}
            phx-click={JS.navigate(~p"/blogs/#{blog}")}
            class="group flex flex-col bg-base-300 rounded-2xl border border-zinc-200 overflow-hidden cursor-pointer hover:shadow-md hover:-translate-y-0.5 transition-all duration-200"
          >
            <.blog_card blog={blog} />
          </article>
        </div>
      </.async_result>
    </section>
    """
  end

  def section_header(assigns) do
    ~H"""
    <div class="flex items-end justify-between">
      <div>
        <p class="text-xs font-semibold uppercase tracking-widest text-base-content/50 mb-1">
          Highlighted
        </p>

        <h2 class="text-2xl font-bold text-base-content leading-tight">
          Featured Blogs
        </h2>
      </div>

      <.link
        navigate={~p"/"}
        class="text-sm font-medium text-base-content/70 hover:text-primary transition-colors flex items-center gap-1"
      >
        View all <.icon name="hero-arrow-right" class="size-3.5" />
      </.link>
    </div>
    """
  end
end
