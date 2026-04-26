defmodule PhxlogWeb.BlogLive.Show.Likes do
  alias Phxlog.Blogs

  def assign_likes(socket, blog) do
    socket
    |> Phoenix.Component.assign(:likes_count, Blogs.likes_count(blog))
    |> Phoenix.Component.assign(
      :liked,
      Blogs.liked_by_user?(blog, socket.assigns[:current_scope])
    )
  end

  def handle_info({:likes_updated, count}, socket) do
    Phoenix.LiveView.send_update(PhxlogWeb.Components.LikeLive,
      id: "like-button",
      likes_count: count,
      liked: Blogs.liked_by_user?(socket.assigns.blog, socket.assigns[:current_scope])
    )

    {:noreply, socket}
  end

  def handle_info({:like_live, :not_logged_in}, socket) do
    {:noreply, Phoenix.LiveView.put_flash(socket, :error, "You must be logged in to like.")}
  end

  def handle_info({:like_live, :error}, socket) do
    {:noreply, Phoenix.LiveView.put_flash(socket, :error, "Something went wrong.")}
  end
end
