defmodule PhxlogWeb.Blogs.LoadingState do
  @moduledoc """
  Reusable loading state UI component.

  Displays a centered loading indicator while async data is being fetched.
  Typically used in blog grids, featured sections, and async views.
  """
  use PhxlogWeb, :html

  def loading_state(assigns) do
    ~H"""
    <div class="flex justify-center items-center mt-[20vh]">
      <span class="loading loading-bars text-primary loading-xl"></span>
    </div>
    """
  end
end
