defmodule PhxlogWeb.Blogs.BlogGrid do
  use PhxlogWeb, :html
  import PhxlogWeb.Blogs.BlogCard
  import PhxlogWeb.Blogs.EmptyState
  import PhxlogWeb.Blogs.LoadingState
  import PhxlogWeb.Blogs.ErrorState

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
