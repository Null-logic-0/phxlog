defmodule PhxlogWeb.Components.LikeLive do
  use PhxlogWeb, :live_component
  alias Phxlog.Blogs

  def update(assigns, socket) do
    {:ok, assign(socket, assigns)}
  end

  def render(assigns) do
    ~H"""
    <button
      type="button"
      phx-click="toggle_like"
      phx-target={@myself}
      class={[
        "flex items-center cursor-pointer gap-2 px-4 py-2 rounded-full border transition-all duration-200 font-medium text-sm",
        if(@liked,
          do: "border-error text-error bg-error/10 hover:bg-error/20",
          else:
            "border-base-300 text-base-content/50 hover:border-error hover:text-error hover:bg-error/10"
        )
      ]}
    >
      <.icon name={if(@liked, do: "hero-heart-solid", else: "hero-heart")} class="size-5" />
      <span>{@likes_count}</span>
    </button>
    """
  end

  def handle_event("toggle_like", _params, socket) do
    case socket.assigns[:current_scope] do
      nil ->
        send(self(), {:like_live, :not_logged_in})
        {:noreply, socket}

      scope ->
        case Blogs.toggle_like(scope, socket.assigns.blog) do
          :error ->
            send(self(), {:like_live, :error})
            {:noreply, socket}

          _ ->
            liked = !socket.assigns.liked

            likes_count =
              if liked,
                do: socket.assigns.likes_count + 1,
                else: socket.assigns.likes_count - 1

            {:noreply,
             socket
             |> assign(:liked, liked)
             |> assign(:likes_count, likes_count)}
        end
    end
  end
end
