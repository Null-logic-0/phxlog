defmodule PhxlogWeb.Blogs.ErrorState do
  @moduledoc """
  Reusable error state UI component.

  Displays a styled error message block with an icon and reason text.
  Used when blog data fails to load or an operation returns an error.
  """
  use PhxlogWeb, :html

  @doc """
  Renders an error state message.

  ## Assigns

    * `:reason` - error message to display (required)

  ## Example

      <.error_state reason="Database connection failed" />
  """
  attr :reason, :string, required: true

  def error_state(assigns) do
    ~H"""
    <div class="flex items-start gap-4 rounded-2xl border border-red-100 bg-red-50 p-5">
      <div class="mt-0.5 flex-shrink-0 w-8 h-8 rounded-full bg-red-100 flex items-center justify-center">
        <.icon name="hero-exclamation-triangle" class="size-4 text-red-500" />
      </div>
      <div>
        <p class="text-sm font-semibold text-red-700">Failed to load blogs</p>
        <p class="text-sm text-red-500 mt-0.5">{@reason}</p>
      </div>
    </div>
    """
  end
end
