defmodule PhxlogWeb.Blogs.LoadingState do
  use PhxlogWeb, :html

  def loading_state(assigns) do
    ~H"""
    <div class="flex justify-center items-center mt-[20vh]">
      <span class="loading loading-bars text-primary loading-xl"></span>
    </div>
    """
  end
end
