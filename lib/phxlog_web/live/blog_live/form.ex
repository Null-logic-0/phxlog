defmodule PhxlogWeb.BlogLive.Form do
  use PhxlogWeb, :live_view

  alias Phxlog.Blogs
  alias Phxlog.Blogs.Blog

  @impl true
  def mount(params, _session, socket) do
    socket = assign(socket, :live_action, socket.assigns.live_action)

    socket =
      socket
      |> assign(:return_to, return_to(params["return_to"]))
      |> apply_action(socket.assigns.live_action, params)

    socket =
      allow_upload(
        socket,
        :photo,
        accept: ~w(.png .jpeg .jpg),
        max_entries: 1,
        max_file_size: 10_000_000
      )

    {:ok, socket}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  defp apply_action(socket, :edit, %{"id" => id}) do
    blog = Blogs.get_blog!(id)

    socket
    |> assign(:page_title, "Edit #{blog.title}")
    |> assign(:blog, blog)
    |> assign(:form, to_form(Blogs.change_blog(blog)))
  end

  defp apply_action(socket, :new, _params) do
    blog = %Blog{}

    socket
    |> assign(:page_title, "New Blog")
    |> assign(:blog, blog)
    |> assign(:form, to_form(Blogs.change_blog(blog)))
  end

  @impl true
  def handle_event("validate", %{"blog" => blog_params}, socket) do
    changeset = Blogs.change_blog(socket.assigns.blog, blog_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"blog" => blog_params}, socket) do
    save_blog(socket, socket.assigns.live_action, blog_params)
  end

  def handle_event("cancel", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :photo, ref)}
  end

  defp save_blog(socket, :edit, blog_params) do
    blog_params = file_upload(socket, blog_params)

    handle_save(
      socket,
      Blogs.update_blog(socket.assigns.blog, blog_params),
      "Blog updated successfully",
      fn blog -> return_path(socket.assigns.return_to, blog) end
    )
  end

  defp save_blog(socket, :new, blog_params) do
    blog_params = file_upload(socket, blog_params)

    handle_save(
      socket,
      Blogs.create_blog(blog_params),
      "Blog created successfully",
      fn blog -> return_path(socket.assigns.return_to, blog) end
    )
  end

  defp handle_save(socket, result, message, navigate) do
    case result do
      {:ok, record} ->
        {:noreply,
         socket
         |> put_flash(:info, message)
         |> push_navigate(to: navigate.(record))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp file_upload(socket, blog_params) do
    image_path =
      case consume_uploaded_entries(socket, :photo, fn meta, entry ->
             dest =
               Path.join([
                 "priv",
                 "static",
                 "uploads",
                 "#{entry.uuid}-#{entry.client_name}"
               ])

             File.cp!(meta.path, dest)

             {:ok, static_path(socket, "/uploads/#{Path.basename(dest)}")}
           end) do
        [path] -> path
        [] -> nil
      end

    if image_path do
      Map.put(blog_params, "image_path", image_path)
    else
      blog_params
    end
  end

  defp return_path("index", _blog), do: ~p"/admin/blogs"
  defp return_path("show", blog), do: ~p"/blogs/#{blog}"
end
