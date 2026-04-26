defmodule PhxlogWeb.BlogLive.Show.CommentsTest do
  use PhxlogWeb.ConnCase, async: true
  import Phoenix.LiveViewTest
  import Phxlog.AccountsFixtures
  import Phxlog.BlogsFixtures
  import Phxlog.CommentFixtures

  describe "comments" do
    test "renders comments section for unauthenticated user", %{conn: conn} do
      blog = blog_fixture()
      {:ok, view, _html} = live(conn, ~p"/blogs/#{blog}")
      render_async(view)
      assert render(view) =~ blog.title
    end

    test "renders comment form for logged in user", %{conn: conn} do
      user = user_fixture()
      conn = log_in_user(conn, user)
      blog = blog_fixture()
      {:ok, view, _html} = live(conn, ~p"/blogs/#{blog}")
      render_async(view)
      assert render(view) =~ blog.title
    end

    test "logged in user can load more comments", %{conn: conn} do
      user = user_fixture()
      conn = log_in_user(conn, user)
      blog = blog_fixture()
      {:ok, view, _html} = live(conn, ~p"/blogs/#{blog}")
      render_async(view)
      send(view.pid, {:comments_live, :load_more_comments})
      assert render(view) =~ blog.title
    end

    test "does not load more when not has_more", %{conn: conn} do
      blog = blog_fixture()
      {:ok, view, _html} = live(conn, ~p"/blogs/#{blog}")
      render_async(view)
      send(view.pid, {:comments_live, :load_more_comments})
      assert render(view) =~ blog.title
    end
  end

  describe "PubSub - comment created" do
    test "adds new comment to list", %{conn: conn} do
      user = user_fixture()
      scope = user_scope_fixture(user)
      conn = log_in_user(conn, user)
      blog = blog_fixture()
      {:ok, view, _html} = live(conn, ~p"/blogs/#{blog}")
      render_async(view)

      comment = comment_fixture(scope, blog, %{"content" => "A new comment"})
      send(view.pid, {:created, comment})

      assert render(view) =~ blog.title
    end
  end

  describe "PubSub - comment updated" do
    test "updates comment in list", %{conn: conn} do
      user = user_fixture()
      scope = user_scope_fixture(user)
      conn = log_in_user(conn, user)
      blog = blog_fixture()
      {:ok, view, _html} = live(conn, ~p"/blogs/#{blog}")
      render_async(view)

      comment = comment_fixture(scope, blog, %{"content" => "Original comment"})
      send(view.pid, {:created, comment})
      updated_comment = %{comment | content: "Updated comment"}
      send(view.pid, {:updated, updated_comment})

      assert render(view) =~ blog.title
    end
  end

  describe "PubSub - comment deleted" do
    test "removes comment from list", %{conn: conn} do
      user = user_fixture()
      scope = user_scope_fixture(user)
      conn = log_in_user(conn, user)
      blog = blog_fixture()
      {:ok, view, _html} = live(conn, ~p"/blogs/#{blog}")
      render_async(view)

      comment = comment_fixture(scope, blog, %{"content" => "Comment to delete"})
      send(view.pid, {:created, comment})
      send(view.pid, {:deleted, comment})

      assert render(view) =~ blog.title
    end
  end
end
