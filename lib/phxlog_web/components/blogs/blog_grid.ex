defmodule PhxlogWeb.Blogs.BlogGrid do
  @moduledoc """
  Grid layout component for displaying a collection of blog cards.

  Handles UI states for:
  - Loading
  - Error
  - Empty state
  - Blog grid rendering

  Each blog is rendered using `BlogCard` inside a responsive grid layout.
  """

  use PhxlogWeb, :html

  import PhxlogWeb.Blogs.BlogCard
  import PhxlogWeb.Blogs.EmptyState
  import PhxlogWeb.Blogs.LoadingState
  import PhxlogWeb.Blogs.ErrorState

  @doc """
  Renders a responsive grid of blog cards with UI states.

  ## Assigns

    * `:blogs` - enumerable of `{dom_id, blog}` tuples (required)
    * `:count` - total number of blogs (used for empty/loading logic)
    * `:error` - error message string (if any)
    * `:empty_label` - title for empty state
    * `:empty_sublabel` - subtitle for empty state

  ## Behavior

  - Shows loading state when `count` and `error` are `nil`
  - Shows error state when `error` is present
  - Shows empty state when `count == 0`
  - Otherwise renders a responsive grid of blog cards

  ## Example

      <.blog_grid blogs={@streams.blogs} count={@count} />
  """
  attr :blogs, :any, required: true
  attr :count, :integer, default: nil
  attr :error, :string, default: nil
  attr :empty_label, :string, default: "No blogs yet"
  attr :empty_sublabel, :string, default: "Check back soon for new posts"

  def blog_grid(assigns) do
    ~H"""
    <.loading_state :if={is_nil(@count) && is_nil(@error)} />
    <.error_state :if={@error} reason={@error} />
    <.empty_state :if={@count == 0} label={@empty_label} sublabel={@empty_sublabel} />

    <div
      :if={is_nil(@count) || @count > 0}
      id="blogs"
      class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6 w-full"
    >
      <article
        :for={{dom_id, blog} <- @blogs}
        id={dom_id}
        phx-click={JS.navigate(~p"/blogs/#{blog}")}
        class="group flex flex-col bg-base-300 rounded-2xl overflow-hidden cursor-pointer hover:shadow-md hover:-translate-y-0.5 transition-all duration-200"
      >
        <.blog_card blog={blog} />
      </article>
    </div>
    """
  end
end
