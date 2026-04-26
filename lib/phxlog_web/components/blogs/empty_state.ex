defmodule PhxlogWeb.Blogs.EmptyState do
  @moduledoc """
  Reusable empty state UI component.

  Displays a centered message with an icon, title, and subtitle.
  Used for cases where no data is available (e.g. empty blog list).
  """
  use PhxlogWeb, :html

  @doc """
  Renders an empty state block.

  ## Assigns

    * `:label` - main message shown to the user
    * `:sublabel` - secondary helper text
    * `:icon` - heroicon name to display (default: "hero-newspaper")

  ## Example

      <.empty_state
        label="No blogs yet"
        sublabel="Check back soon"
        icon="hero-document-text"
      />
  """
  attr :label, :string, default: "Nothing here yet"
  attr :sublabel, :string, default: "Check back soon"
  attr :icon, :string, default: "hero-newspaper"

  def empty_state(assigns) do
    ~H"""
    <div class="flex flex-col items-center justify-center py-20 text-center rounded-2xl border border-dashed border-base-400">
      <div class="w-14 h-14 rounded-full bg-secondary flex items-center justify-center mb-4">
        <.icon name={@icon} class="size-8 text-white" />
      </div>
      <p class="text-sm font-semibold text-base-content">{@label}</p>
      <p class="text-xs text-zinc-500 mt-1">{@sublabel}</p>
    </div>
    """
  end
end
