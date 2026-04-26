defmodule Phxlog.BlogsTest do
  use Phxlog.DataCase

  alias Phxlog.Blogs

  describe "blogs" do
    alias Phxlog.Blogs.Blog

    import Phxlog.BlogsFixtures

    @invalid_attrs %{title: nil, content: nil, image_path: nil}

    test "list_blogs/0 returns all blogs" do
      blog = blog_fixture()
      assert Blogs.list_blogs() == [blog]
    end

    test "get_blog!/1 returns the blog with given id" do
      blog = blog_fixture()
      assert Blogs.get_blog!(blog.id) == blog
    end

    test "create_blog/1 with valid data creates a blog" do
      valid_attrs = %{title: "some title", content: "some content", image_path: "some image_path"}

      assert {:ok, %Blog{} = blog} = Blogs.create_blog(valid_attrs)
      assert blog.title == "some title"
      assert blog.content == "some content"
      assert blog.image_path == "some image_path"
    end

    test "create_blog/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Blogs.create_blog(@invalid_attrs)
    end

    test "update_blog/2 with valid data updates the blog" do
      blog = blog_fixture()
      update_attrs = %{title: "some updated title", content: "some updated content", image_path: "some updated image_path"}

      assert {:ok, %Blog{} = blog} = Blogs.update_blog(blog, update_attrs)
      assert blog.title == "some updated title"
      assert blog.content == "some updated content"
      assert blog.image_path == "some updated image_path"
    end

    test "update_blog/2 with invalid data returns error changeset" do
      blog = blog_fixture()
      assert {:error, %Ecto.Changeset{}} = Blogs.update_blog(blog, @invalid_attrs)
      assert blog == Blogs.get_blog!(blog.id)
    end

    test "delete_blog/1 deletes the blog" do
      blog = blog_fixture()
      assert {:ok, %Blog{}} = Blogs.delete_blog(blog)
      assert_raise Ecto.NoResultsError, fn -> Blogs.get_blog!(blog.id) end
    end

    test "change_blog/1 returns a blog changeset" do
      blog = blog_fixture()
      assert %Ecto.Changeset{} = Blogs.change_blog(blog)
    end
  end

  describe "comments" do
    alias Phxlog.Blogs.Comment

    import Phxlog.AccountsFixtures, only: [user_scope_fixture: 0]
    import Phxlog.BlogsFixtures

    @invalid_attrs %{content: nil}

    test "list_comments/1 returns all scoped comments" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      comment = comment_fixture(scope)
      other_comment = comment_fixture(other_scope)
      assert Blogs.list_comments(scope) == [comment]
      assert Blogs.list_comments(other_scope) == [other_comment]
    end

    test "get_comment!/2 returns the comment with given id" do
      scope = user_scope_fixture()
      comment = comment_fixture(scope)
      other_scope = user_scope_fixture()
      assert Blogs.get_comment!(scope, comment.id) == comment
      assert_raise Ecto.NoResultsError, fn -> Blogs.get_comment!(other_scope, comment.id) end
    end

    test "create_comment/2 with valid data creates a comment" do
      valid_attrs = %{content: "some content"}
      scope = user_scope_fixture()

      assert {:ok, %Comment{} = comment} = Blogs.create_comment(scope, valid_attrs)
      assert comment.content == "some content"
      assert comment.user_id == scope.user.id
    end

    test "create_comment/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Blogs.create_comment(scope, @invalid_attrs)
    end

    test "update_comment/3 with valid data updates the comment" do
      scope = user_scope_fixture()
      comment = comment_fixture(scope)
      update_attrs = %{content: "some updated content"}

      assert {:ok, %Comment{} = comment} = Blogs.update_comment(scope, comment, update_attrs)
      assert comment.content == "some updated content"
    end

    test "update_comment/3 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      comment = comment_fixture(scope)

      assert_raise MatchError, fn ->
        Blogs.update_comment(other_scope, comment, %{})
      end
    end

    test "update_comment/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      comment = comment_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Blogs.update_comment(scope, comment, @invalid_attrs)
      assert comment == Blogs.get_comment!(scope, comment.id)
    end

    test "delete_comment/2 deletes the comment" do
      scope = user_scope_fixture()
      comment = comment_fixture(scope)
      assert {:ok, %Comment{}} = Blogs.delete_comment(scope, comment)
      assert_raise Ecto.NoResultsError, fn -> Blogs.get_comment!(scope, comment.id) end
    end

    test "delete_comment/2 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      comment = comment_fixture(scope)
      assert_raise MatchError, fn -> Blogs.delete_comment(other_scope, comment) end
    end

    test "change_comment/2 returns a comment changeset" do
      scope = user_scope_fixture()
      comment = comment_fixture(scope)
      assert %Ecto.Changeset{} = Blogs.change_comment(scope, comment)
    end
  end
end
