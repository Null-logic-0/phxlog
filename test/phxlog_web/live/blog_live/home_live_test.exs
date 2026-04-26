defmodule PhxlogWeb.BlogLive.HomeLiveTest do
  use PhxlogWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import Phxlog.AccountsFixtures
  import Phxlog.BlogsFixtures

  describe "mount and initial render" do
    test "renders the page with All Blogs heading", %{conn: conn} do
      {:ok, _view, html} = live(conn, ~p"/")
      assert html =~ "All Blogs"
    end

    test "renders search input", %{conn: conn} do
      {:ok, _view, html} = live(conn, ~p"/")
      assert html =~ "Search..."
    end

    test "renders for logged in user", %{conn: conn} do
      user = user_fixture()
      conn = log_in_user(conn, user)
      {:ok, _view, html} = live(conn, ~p"/")
      assert html =~ "All Blogs"
    end
  end

  describe "search" do
    test "filters blogs by title", %{conn: conn} do
      blog = blog_fixture(%{title: "Elixir Rocks XYZ"})
      _other = blog_fixture(%{title: "Something Totally Different"})

      {:ok, view, _html} = live(conn, ~p"/")

      view
      |> form("#search-form", %{"q" => "Elixir Rocks XYZ"})
      |> render_change()

      assert_patch(view, ~p"/?q=Elixir+Rocks+XYZ")
      html = render_async(view)
      assert html =~ blog.title
      refute html =~ "Something Totally Different"
    end

    test "updates URL params on search", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      view
      |> form("#search-form", %{"q" => "elixir"})
      |> render_change()

      assert_patch(view, ~p"/?q=elixir")
    end
  end

  describe "pagination" do
    test "navigates to page 2", %{conn: conn} do
      Enum.each(1..10, fn i ->
        blog_fixture(%{title: "Blog Number #{i}"})
      end)

      {:ok, view, _html} = live(conn, ~p"/?page=2")
      html = render(view)
      assert html =~ "All Blogs"
    end
  end

  describe "PubSub - blog_created" do
    test "reloads blogs when a new blog is created", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")
      render_async(view)

      blog = blog_fixture(%{title: "Brand New Blog Post"})
      send(view.pid, {:blog_created, blog})

      html = render_async(view)
      assert html =~ blog.title
    end
  end

  describe "PubSub - blog_updated" do
    test "reloads blogs when a blog is updated", %{conn: conn} do
      blog = blog_fixture(%{title: "Original Title"})
      {:ok, view, _html} = live(conn, ~p"/")
      render(view)

      updated_blog = %{blog | title: "Updated Title"}
      send(view.pid, {:blog_updated, updated_blog})

      html = render(view)
      assert html =~ "All Blogs"
    end
  end

  describe "PubSub - blog_deleted" do
    test "reloads blogs when a blog is deleted", %{conn: conn} do
      blog = blog_fixture()
      {:ok, view, _html} = live(conn, ~p"/")
      render(view)

      send(view.pid, {:blog_deleted, blog})

      html = render(view)
      assert html =~ "All Blogs"
    end

    test "does not crash when blogs_count is nil", %{conn: conn} do
      blog = blog_fixture()
      {:ok, view, _html} = live(conn, ~p"/")

      send(view.pid, {:blog_deleted, blog})

      assert render(view) =~ "All Blogs"
    end
  end
end
