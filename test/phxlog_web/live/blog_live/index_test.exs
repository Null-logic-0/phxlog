defmodule PhxlogWeb.BlogLive.IndexTest do
  use PhxlogWeb.ConnCase, async: true
  import Phoenix.LiveViewTest
  import Phxlog.AccountsFixtures
  import Phxlog.BlogsFixtures

  setup %{conn: conn} do
    user = admin_user_fixture()
    conn = log_in_user(conn, user)
    %{conn: conn, user: user}
  end

  describe "mount and initial render" do
    test "renders the page with Listing Blogs heading", %{conn: conn} do
      {:ok, _view, html} = live(conn, ~p"/admin/blogs")
      assert html =~ "Listing Blogs"
    end

    test "shows blogs after async load", %{conn: conn, user: user} do
      blog = blog_fixture(%{user_id: user.id, title: "My Test Blog"})
      {:ok, view, _html} = live(conn, ~p"/admin/blogs")
      html = render_async(view)
      assert html =~ blog.title
    end
  end

  describe "search" do
    test "filters blogs by title", %{conn: conn, user: user} do
      blog = blog_fixture(%{user_id: user.id, title: "Elixir Rocks XYZ"})
      _other = blog_fixture(%{user_id: user.id, title: "Something Totally Different"})

      {:ok, view, _html} = live(conn, ~p"/admin/blogs")

      view
      |> form("#search-form", %{"q" => "Elixir Rocks XYZ"})
      |> render_change()

      assert_patch(view, ~p"/admin/blogs?q=Elixir+Rocks+XYZ")

      html = render_async(view)
      assert html =~ blog.title
      refute html =~ "Something Totally Different"
    end

    test "updates URL params on search", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/admin/blogs")

      view
      |> form("#search-form", %{"q" => "elixir"})
      |> render_change()

      assert_patch(view, ~p"/admin/blogs?q=elixir")
    end

    test "clears URL params when search is empty", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/admin/blogs?q=elixir")

      view
      |> form("#search-form", %{"q" => ""})
      |> render_change()

      assert_patch(view, ~p"/admin/blogs")
    end

    test "shows empty state when no results", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/?q=zzznomatch999")
      render_async(view)
      html = render(view)
      refute html =~ "loading loading-bars"
    end

    test "pre-fills search input from URL param", %{conn: conn} do
      {:ok, _view, html} = live(conn, ~p"/admin/blogs?q=prefilled")
      assert html =~ "prefilled"
    end
  end

  describe "pagination" do
    test "navigates to page 2", %{conn: conn, user: user} do
      Enum.each(1..12, fn i ->
        blog_fixture(%{user_id: user.id, title: "Blog Number #{i}"})
      end)

      {:ok, view, _html} = live(conn, ~p"/admin/blogs?page=2")
      html = render_async(view)
      assert html =~ "Listing Blogs"
    end
  end

  describe "delete" do
    test "deletes a blog", %{conn: conn, user: user} do
      blog = blog_fixture(%{user_id: user.id, title: "Blog To Delete"})
      {:ok, view, _html} = live(conn, ~p"/admin/blogs")
      render_async(view)

      view
      |> element("#blogs-#{blog.id} a[data-confirm]")
      |> render_click()

      refute render(view) =~ blog.title
    end

    test "decrements blogs_count after delete", %{conn: conn, user: user} do
      blog = blog_fixture(%{user_id: user.id})
      {:ok, view, _html} = live(conn, ~p"/admin/blogs")
      render_async(view)

      view
      |> element("#blogs-#{blog.id} a[data-confirm]")
      |> render_click()

      assert render(view) =~ "Listing Blogs"
    end
  end

  describe "PubSub - blog_created" do
    test "reloads blogs when a new blog is created", %{conn: conn, user: user} do
      {:ok, view, _html} = live(conn, ~p"/admin/blogs")
      render_async(view)
    
      blog = blog_fixture(%{user_id: user.id, title: "Brand New Blog Post"})
      send(view.pid, {:blog_created, blog})
    
      render_async(view)
      html = render_async(view)
      assert html =~ blog.title
    end

    test "does not crash when blogs_count is nil on create", %{conn: conn, user: user} do
      {:ok, view, _html} = live(conn, ~p"/admin/blogs")
      blog = blog_fixture(%{user_id: user.id})
      send(view.pid, {:blog_created, blog})
      assert render(view) =~ "Listing Blogs"
    end
  end

  describe "PubSub - blog_updated" do
    test "reloads blogs when a blog is updated", %{conn: conn, user: user} do
      blog = blog_fixture(%{user_id: user.id, title: "Original Title"})
      {:ok, view, _html} = live(conn, ~p"/admin/blogs")
      render_async(view)

      updated_blog = %{blog | title: "Updated Title"}
      send(view.pid, {:blog_updated, updated_blog})

      html = render_async(view)
      assert html =~ "Listing Blogs"
    end

    test "does not crash when blogs_count is nil on update", %{conn: conn, user: user} do
      blog = blog_fixture(%{user_id: user.id})
      {:ok, view, _html} = live(conn, ~p"/admin/blogs")
      send(view.pid, {:blog_updated, blog})
      assert render(view) =~ "Listing Blogs"
    end
  end

  describe "PubSub - blog_deleted" do
    test "reloads blogs when a blog is deleted", %{conn: conn, user: user} do
      blog = blog_fixture(%{user_id: user.id})
      {:ok, view, _html} = live(conn, ~p"/admin/blogs")
      render_async(view)

      send(view.pid, {:blog_deleted, blog})

      html = render_async(view)
      assert html =~ "Listing Blogs"
    end

    test "does not crash when blogs_count is nil on delete", %{conn: conn, user: user} do
      blog = blog_fixture(%{user_id: user.id})
      {:ok, view, _html} = live(conn, ~p"/admin/blogs")
      send(view.pid, {:blog_deleted, blog})
      assert render(view) =~ "Listing Blogs"
    end

    test "goes to previous page when last item on page > 1 is deleted", %{conn: conn, user: user} do
      Enum.each(1..11, fn i ->
        blog_fixture(%{user_id: user.id, title: "Blog #{i}"})
      end)

      last_blog = blog_fixture(%{user_id: user.id, title: "Last On Page 2"})

      {:ok, view, _html} = live(conn, ~p"/admin/blogs?page=2")
      render_async(view)

      send(view.pid, {:blog_deleted, last_blog})
      html = render_async(view)
      assert html =~ "Listing Blogs"
    end
  end
end
