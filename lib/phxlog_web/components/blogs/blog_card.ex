defmodule PhxlogWeb.Blogs.BlogCard do
  @moduledoc """
  UI component for rendering a blog preview card.

  Displays:
  - Blog image (or fallback placeholder)
  - Title
  - Short content preview
  - Publication date
  - "Read more" indicator

  Designed to be used in blog listings, grids, or feeds.
  """
  use PhxlogWeb, :html
  alias Phxlog.Blogs.Blog

  @doc """
  Renders a blog card.

  ## Assigns

    * `:blog` - `%Blog{}` struct (required)

  ## Slots

    * `:image` - override image section
    * `:title` - override title
    * `:content` - override content preview
    * `:meta` - override footer/meta section

  ## Examples

      <.blog_card blog={@blog} />

      <.blog_card blog={@blog}>
        <:title>
          <h2 class="text-lg font-bold text-red-500">
            {@blog.title}
          </h2>
        </:title>
      </.blog_card>
  """

  attr :blog, Blog, required: true

  def blog_card(assigns) do
    ~H"""
    <div class="relative h-48 bg-base-200 overflow-hidden flex-shrink-0">
      <%= if @blog.image_path do %>
        <img
          src={@blog.image_path}
          alt={@blog.title}
          class="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300"
        />
      <% else %>
        <div class="w-full h-full flex items-center justify-center bg-base-200">
          <.icon name="hero-photo" class="size-10 text-base-content/30" />
        </div>
      <% end %>
    </div>

    <div class="flex flex-col flex-1 p-5 gap-2">
      <h2 class="text-base-content font-semibold leading-snug line-clamp-2 group-hover:text-primary transition-colors">
        {@blog.title}
      </h2>

      <p class="text-sm text-base-content/70 leading-relaxed line-clamp-3 flex-1 truncate">
        {@blog.content}
      </p>

      <div class="flex items-center justify-between pt-3 mt-auto border-t border-base-400">
        <span class="text-xs text-base-content/50">
          {Calendar.strftime(@blog.inserted_at, "%b %d, %Y")}
        </span>

        <span class="text-xs font-medium text-base-content/70 flex items-center gap-1 group-hover:text-primary transition-colors">
          Read more <.icon name="hero-arrow-right" class="size-3" />
        </span>
      </div>
    </div>
    """
  end
end
