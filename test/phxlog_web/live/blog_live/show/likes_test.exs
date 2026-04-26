defmodule PhxlogWeb.BlogLive.Show.LikesTest do
  use PhxlogWeb.ConnCase, async: true
  import Phoenix.LiveViewTest
  import Phxlog.AccountsFixtures
  import Phxlog.BlogsFixtures

  describe "likes display" do
    test "shows likes count for unauthenticated user", %{conn: conn} do
      blog = blog_fixture()
      {:ok, _view, html} = live(conn, ~p"/blogs/#{blog}")
      assert html =~ blog.title
    end

    test "shows likes count for logged in user", %{conn: conn} do
      user = user_fixture()
      conn = log_in_user(conn, user)
      blog = blog_fixture()
      {:ok, _view, html} = live(conn, ~p"/blogs/#{blog}")
      assert html =~ blog.title
    end
  end

  describe "PubSub - likes_updated" do
    test "updates likes count when likes_updated is received", %{conn: conn} do
      blog = blog_fixture()
      {:ok, view, _html} = live(conn, ~p"/blogs/#{blog}")

      send(view.pid, {:likes_updated, 5})

      assert render(view) =~ blog.title
    end

    test "updates likes count for logged in user", %{conn: conn} do
      user = user_fixture()
      conn = log_in_user(conn, user)
      blog = blog_fixture()
      {:ok, view, _html} = live(conn, ~p"/blogs/#{blog}")

      send(view.pid, {:likes_updated, 3})

      assert render(view) =~ blog.title
    end
  end

  describe "PubSub - like_live" do
    test "shows error flash when not logged in", %{conn: conn} do
      blog = blog_fixture()
      {:ok, view, _html} = live(conn, ~p"/blogs/#{blog}")

      send(view.pid, {:like_live, :not_logged_in})

      assert render(view) =~ "You must be logged in to like"
    end

    test "shows error flash on like error", %{conn: conn} do
      blog = blog_fixture()
      {:ok, view, _html} = live(conn, ~p"/blogs/#{blog}")

      send(view.pid, {:like_live, :error})

      assert render(view) =~ "Something went wrong"
    end
  end
end
