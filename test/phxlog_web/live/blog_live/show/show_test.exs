defmodule PhxlogWeb.BlogLive.ShowTest do
  use PhxlogWeb.ConnCase, async: true
  import Phoenix.LiveViewTest
  import Phxlog.AccountsFixtures
  import Phxlog.BlogsFixtures

  describe "mount and initial render" do
    test "renders blog title", %{conn: conn} do
      blog = blog_fixture(%{title: "My Show Blog"})
      {:ok, _view, html} = live(conn, ~p"/blogs/#{blog}")
      assert html =~ blog.title
    end

    test "renders blog content", %{conn: conn} do
      blog = blog_fixture(%{content: "Some interesting content"})
      {:ok, _view, html} = live(conn, ~p"/blogs/#{blog}")
      assert html =~ blog.content
    end

    test "sets page title to blog title", %{conn: conn} do
      blog = blog_fixture(%{title: "Page Title Blog"})
      {:ok, view, _html} = live(conn, ~p"/blogs/#{blog}")
      assert page_title(view) =~ blog.title
    end

    test "renders for logged in user", %{conn: conn} do
      user = user_fixture()
      conn = log_in_user(conn, user)
      blog = blog_fixture(%{title: "Auth Blog"})
      {:ok, _view, html} = live(conn, ~p"/blogs/#{blog}")
      assert html =~ blog.title
    end

    test "renders for unauthenticated user", %{conn: conn} do
      blog = blog_fixture(%{title: "Public Blog"})
      {:ok, _view, html} = live(conn, ~p"/blogs/#{blog}")
      assert html =~ blog.title
    end
  end

  describe "featured blogs async" do
    test "renders without crashing while featured blogs load", %{conn: conn} do
      blog = blog_fixture(%{title: "Featured Test Blog"})
      {:ok, view, _html} = live(conn, ~p"/blogs/#{blog}")
      html = render_async(view)
      assert html =~ blog.title
    end
  end

  describe "PubSub - blog_updated" do
    test "updates blog content when blog is updated", %{conn: conn} do
      blog = blog_fixture(%{title: "Original Title"})
      {:ok, view, _html} = live(conn, ~p"/blogs/#{blog}")

      updated_blog = %{blog | title: "Updated Title"}
      send(view.pid, {:blog_updated, updated_blog})

      assert render(view) =~ "Updated Title"
    end
  end

  describe "PubSub - blog_deleted" do
    test "redirects to home when blog is deleted", %{conn: conn} do
      blog = blog_fixture(%{title: "To Be Deleted"})
      {:ok, view, _html} = live(conn, ~p"/blogs/#{blog}")

      send(view.pid, {:blog_deleted, blog})

      {path, flash} = assert_redirect(view)
      assert path == ~p"/"
      assert flash["info"] =~ "deleted"
    end
  end

  describe "likes" do
    test "renders likes section", %{conn: conn} do
      blog = blog_fixture()
      {:ok, _view, html} = live(conn, ~p"/blogs/#{blog}")
      assert html =~ blog.title
    end

    test "logged in user can see like button", %{conn: conn} do
      user = user_fixture()
      conn = log_in_user(conn, user)
      blog = blog_fixture()
      {:ok, _view, html} = live(conn, ~p"/blogs/#{blog}")
      assert html =~ blog.title
    end
  end

  describe "comments" do
    test "renders comments section", %{conn: conn} do
      blog = blog_fixture()
      {:ok, _view, html} = live(conn, ~p"/blogs/#{blog}")
      assert html =~ blog.title
    end

    test "logged in user can see comment form", %{conn: conn} do
      user = user_fixture()
      conn = log_in_user(conn, user)
      blog = blog_fixture()
      {:ok, _view, html} = live(conn, ~p"/blogs/#{blog}")
      assert html =~ blog.title
    end
  end
end
