defmodule PhxlogWeb.BlogLiveTest do
  use PhxlogWeb.ConnCase

  import Phoenix.LiveViewTest
  import Phxlog.BlogsFixtures

  @create_attrs %{title: "some title", content: "some content", image_path: "some image_path"}
  @update_attrs %{title: "some updated title", content: "some updated content", image_path: "some updated image_path"}
  @invalid_attrs %{title: nil, content: nil, image_path: nil}
  defp create_blog(_) do
    blog = blog_fixture()

    %{blog: blog}
  end

  describe "Index" do
    setup [:create_blog]

    test "lists all blogs", %{conn: conn, blog: blog} do
      {:ok, _index_live, html} = live(conn, ~p"/blogs")

      assert html =~ "Listing Blogs"
      assert html =~ blog.title
    end

    test "saves new blog", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/blogs")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Blog")
               |> render_click()
               |> follow_redirect(conn, ~p"/blogs/new")

      assert render(form_live) =~ "New Blog"

      assert form_live
             |> form("#blog-form", blog: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#blog-form", blog: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/blogs")

      html = render(index_live)
      assert html =~ "Blog created successfully"
      assert html =~ "some title"
    end

    test "updates blog in listing", %{conn: conn, blog: blog} do
      {:ok, index_live, _html} = live(conn, ~p"/blogs")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#blogs-#{blog.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/blogs/#{blog}/edit")

      assert render(form_live) =~ "Edit Blog"

      assert form_live
             |> form("#blog-form", blog: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#blog-form", blog: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/blogs")

      html = render(index_live)
      assert html =~ "Blog updated successfully"
      assert html =~ "some updated title"
    end

    test "deletes blog in listing", %{conn: conn, blog: blog} do
      {:ok, index_live, _html} = live(conn, ~p"/blogs")

      assert index_live |> element("#blogs-#{blog.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#blogs-#{blog.id}")
    end
  end

  describe "Show" do
    setup [:create_blog]

    test "displays blog", %{conn: conn, blog: blog} do
      {:ok, _show_live, html} = live(conn, ~p"/blogs/#{blog}")

      assert html =~ "Show Blog"
      assert html =~ blog.title
    end

    test "updates blog and returns to show", %{conn: conn, blog: blog} do
      {:ok, show_live, _html} = live(conn, ~p"/blogs/#{blog}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/blogs/#{blog}/edit?return_to=show")

      assert render(form_live) =~ "Edit Blog"

      assert form_live
             |> form("#blog-form", blog: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#blog-form", blog: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/blogs/#{blog}")

      html = render(show_live)
      assert html =~ "Blog updated successfully"
      assert html =~ "some updated title"
    end
  end
end
