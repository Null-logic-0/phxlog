defmodule PhxlogWeb.Blogs.EmptyState do
  use PhxlogWeb, :html

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
