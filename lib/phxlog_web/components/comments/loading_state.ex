defmodule PhxlogWeb.Comments.LoadingState do
  use PhxlogWeb, :html

  def loading_state(assigns) do
    ~H"""
    <div :if={@comments_loading && @comments == []} class="space-y-3">
      <div :for={_ <- 1..5} class="flex gap-3 px-4 py-3 animate-pulse">
        <div class="w-9 h-9 rounded-full bg-base-300 flex-shrink-0"></div>
        <div class="flex-1 space-y-2 pt-1">
          <div class="h-3 bg-base-300 rounded w-1/4"></div>
          <div class="h-3 bg-base-300 rounded w-3/4"></div>
          <div class="h-3 bg-base-300 rounded w-1/2"></div>
        </div>
      </div>
    </div>
    """
  end
end
