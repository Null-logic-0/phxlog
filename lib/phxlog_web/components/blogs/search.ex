defmodule PhxlogWeb.Blogs.Search do
  use PhxlogWeb, :live_component

  attr :form, :any, required: true
  attr :navigate_to, :string, default: "/"
  attr :placeholder, :string, default: "Search..."

  def render(assigns) do
    ~H"""
    <div id={@id}>
      <.form for={@form} id="search-form" phx-change="search" phx-target={@myself}>
        <div class="relative w-full">
          <.icon
            name="hero-magnifying-glass"
            class="size-4 absolute left-3 top-1/2 -translate-y-1/2 text-zinc-400 pointer-events-none"
          />
          <input
            type="text"
            name="q"
            value={@form[:q].value}
            placeholder={@placeholder}
            autocomplete="off"
            phx-debounce="400"
            class="w-full sm:w-sm pl-9 pr-4 py-2 text-sm rounded-xl  bg-base-300 placeholder:text-zinc-400 focus:outline-none focus:ring-2 focus:ring-zinc-900 focus:border-transparent transition"
          />
        </div>
      </.form>
    </div>
    """
  end

  def update(assigns, socket) do
    socket =
      socket
      |> assign(assigns)
      |> assign_new(:navigate_to, fn -> "/" end)
      |> assign_new(:placeholder, fn -> "Search..." end)

    {:ok, assign(socket, assigns)}
  end

  def handle_event("search", %{"q" => q}, socket) do
    params = if q == "", do: %{}, else: %{"q" => q}

    {:noreply,
     push_navigate(socket, to: socket.assigns.navigate_to <> "?#{URI.encode_query(params)}")}
  end
end
