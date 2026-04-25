defmodule PhxlogWeb.Blogs.Pagination do
  use PhxlogWeb, :live_component

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

  defp build_params(page, q) when q in ["", nil], do: URI.encode_query(%{"page" => page})
  defp build_params(page, q), do: URI.encode_query(%{"page" => page, "q" => q})
end
