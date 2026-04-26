defmodule PhxlogWeb.Comments.CommentsToggle do
  use PhxlogWeb, :html

  def comments_toggle(assigns) do
    ~H"""
    <button
      type="button"
      phx-click={
        JS.toggle(
          to: "#comments-panel",
          in:
            {"transition-all duration-300 ease-out", "opacity-0 -translate-y-2",
             "opacity-100 translate-y-0"},
          out:
            {"transition-all duration-200 ease-in", "opacity-100 translate-y-0",
             "opacity-0 -translate-y-2"}
        )
        |> JS.toggle_class("rotate-180", to: "#comments-chevron")
      }
      class="flex items-center gap-3 w-full group"
    >
      <h2 class="text-xl font-bold text-base-content">Comments</h2>
      <div class="badge badge-neutral">{length(@comments_list)}</div>
      <div class="ml-auto cursor-pointer flex items-center gap-1.5 text-sm text-base-content/40 group-hover:text-base-content transition-colors">
        <span>Show / Hide</span>
        <span id="comments-chevron" class="transition-transform duration-300 ease-in-out">
          <.icon name="hero-chevron-down" class="size-4" />
        </span>
      </div>
    </button>
    """
  end
end
