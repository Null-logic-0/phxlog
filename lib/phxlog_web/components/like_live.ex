defmodule PhxlogWeb.Components.LikeLive do
  @moduledoc """
  LiveComponent responsible for handling blog likes.

  This component provides an interactive like button with optimistic UI updates.

  Responsibilities:
  - Toggle like/unlike state for a blog
  - Optimistically update like count in the UI
  - Communicate with `Phxlog.Blogs` context for persistence
  - Notify parent LiveView on auth or error events

  This is a stateful LiveComponent and maintains local UI state.
  """

  use PhxlogWeb, :live_component

  alias Phxlog.Blogs

  @doc """
  Renders the like button UI.

  ## Assigns

    * `:id` - unique DOM id for the component
    * `:blog` - the blog being liked/unliked
    * `:liked` - whether current user has liked the blog
    * `:likes_count` - total number of likes
    * `:current_scope` - current user scope (used for auth)

  ## Events

    * `"toggle_like"` - toggles like state

  ## Behavior

  - If user is not logged in, sends `{:like_live, :not_logged_in}` to parent
  - If toggle fails, sends `{:like_live, :error}`
  - Otherwise updates UI optimistically

  ## Example

      <.live_component
        module={PhxlogWeb.Components.LikeLive}
        id={"like-{@blog.id}"}
        blog={@blog}
        liked={@liked}
        likes_count={@likes_count}
        current_scope={@current_scope}
      />
  """

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

  @doc false
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
