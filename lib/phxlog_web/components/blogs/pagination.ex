defmodule PhxlogWeb.Blogs.Pagination do
  @moduledoc """
  LiveComponent for paginating blog listings.

  Provides navigation between pages with:
  - Previous / Next controls
  - Page number links
  - Query parameter preservation (search support)
  """
  use PhxlogWeb, :live_component

  @doc """
  Renders pagination controls.

  ## Assigns

    * `:id` - DOM id for the component (required)
    * `:meta` - pagination metadata (must include `page`, `total_pages`, `has_prev`, `has_next`)
    * `:base_path` - base route for pagination links (default: "/")
    * `:q` - optional search query string to preserve across pages

  ## Example

      <.live_component
        module={PhxlogWeb.Blogs.Pagination}
        id="blogs-pagination"
        meta={@meta}
        base_path="/blogs"
        q={@q}
      />
  """

  attr :id, :string, required: true
  attr :meta, :map, required: true
  attr :base_path, :string, default: "/"
  attr :q, :string, default: ""

  def render(assigns) do
    ~H"""
    <nav id={@id} class="flex justify-center items-center gap-2 py-6" aria-label="Pagination">
      <.link
        :if={@meta.has_prev}
        patch={"#{@base_path}?#{build_params(@meta.page - 1, @q)}"}
        class="btn btn-sm btn-outline"
      >
        « Prev
      </.link>

      <.link
        :for={page <- 1..@meta.total_pages}
        patch={"#{@base_path}?#{build_params(page, @q)}"}
        class={["btn btn-sm", if(page == @meta.page, do: "btn-primary", else: "btn-outline")]}
        aria-current={if page == @meta.page, do: "page"}
      >
        {page}
      </.link>

      <.link
        :if={@meta.has_next}
        patch={"#{@base_path}?#{build_params(@meta.page + 1, @q)}"}
        class="btn btn-sm btn-outline"
      >
        Next »
      </.link>
    </nav>
    """
  end

  def update(assigns, socket) do
    socket =
      socket
      |> assign(assigns)
      |> assign_new(:base_path, fn -> "/" end)
      |> assign_new(:q, fn -> "" end)

    {:ok, socket}
  end

  @doc false
  defp build_params(page, q) when q in ["", nil], do: URI.encode_query(%{"page" => page})
  defp build_params(page, q), do: URI.encode_query(%{"page" => page, "q" => q})
end
