defmodule PhxlogWeb.BlogLive.FormTest do
  use PhxlogWeb.ConnCase, async: true
  import Phoenix.LiveViewTest
  import Phxlog.AccountsFixtures
  import Phxlog.BlogsFixtures

  setup %{conn: conn} do
    user = admin_user_fixture()
    conn = log_in_user(conn, user)
    %{conn: conn, user: user}
  end

  describe "new blog" do
    test "renders new blog form", %{conn: conn} do
      {:ok, _view, html} = live(conn, ~p"/admin/blogs/new")
      assert html =~ "New Blog"
    end

    test "validates required fields", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/admin/blogs/new")

      view
      |> form("#blog-form", %{"blog" => %{"title" => ""}})
      |> render_change()

      assert render(view) =~ "can&#39;t be blank"
    end

    test "creates blog and redirects to index", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/admin/blogs/new")

      view
      |> form("#blog-form", %{"blog" => %{"title" => "My New Blog", "content" => "Some content"}})
      |> render_submit()

      {path, flash} = assert_redirect(view)
      assert path == ~p"/admin/blogs"
      assert flash["info"] =~ "Blog created successfully"
    end

    test "shows error on invalid submit", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/admin/blogs/new")

      html =
        view
        |> form("#blog-form", %{"blog" => %{"title" => ""}})
        |> render_submit()

      assert html =~ "can&#39;t be blank"
    end
  end

  describe "edit blog" do
    test "renders edit form with existing data", %{conn: conn, user: user} do
      blog = blog_fixture(%{user_id: user.id, title: "Original Title"})
      {:ok, _view, html} = live(conn, ~p"/admin/blogs/#{blog}/edit")
      assert html =~ "Edit #{blog.title}"
      assert html =~ "Original Title"
    end

    test "updates blog and redirects to index", %{conn: conn, user: user} do
      blog = blog_fixture(%{user_id: user.id, title: "Old Title"})
      {:ok, view, _html} = live(conn, ~p"/admin/blogs/#{blog}/edit")

      view
      |> form("#blog-form", %{"blog" => %{"title" => "Updated Title"}})
      |> render_submit()

      {path, flash} = assert_redirect(view)
      assert path == ~p"/admin/blogs"
      assert flash["info"] =~ "Blog updated successfully"
    end

    test "updates blog and redirects to show when return_to=show", %{conn: conn, user: user} do
      blog = blog_fixture(%{user_id: user.id, title: "Show Title"})
      {:ok, view, _html} = live(conn, ~p"/admin/blogs/#{blog}/edit?return_to=show")

      view
      |> form("#blog-form", %{"blog" => %{"title" => "Updated Show Title"}})
      |> render_submit()

      {path, _flash} = assert_redirect(view)
      assert path == ~p"/blogs/#{blog}"
    end

    test "validates on change", %{conn: conn, user: user} do
      blog = blog_fixture(%{user_id: user.id})
      {:ok, view, _html} = live(conn, ~p"/admin/blogs/#{blog}/edit")

      view
      |> form("#blog-form", %{"blog" => %{"title" => ""}})
      |> render_change()

      assert render(view) =~ "can&#39;t be blank"
    end

    test "shows error on invalid submit", %{conn: conn, user: user} do
      blog = blog_fixture(%{user_id: user.id})
      {:ok, view, _html} = live(conn, ~p"/admin/blogs/#{blog}/edit")

      html =
        view
        |> form("#blog-form", %{"blog" => %{"title" => ""}})
        |> render_submit()

      assert html =~ "can&#39;t be blank"
    end
  end

  describe "access control" do
    test "redirects non-admin user to home", %{} do
      user = user_fixture()
      conn = build_conn() |> log_in_user(user)
      assert {:error, {:redirect, %{to: "/"}}} = live(conn, ~p"/admin/blogs/new")
    end

    test "redirects unauthenticated user to login", %{} do
      conn = build_conn()
      assert {:error, {:redirect, %{to: "/users/log-in"}}} = live(conn, ~p"/admin/blogs/new")
    end
  end
end
