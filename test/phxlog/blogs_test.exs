defmodule Phxlog.BlogsTest do
  use Phxlog.DataCase, async: true

  alias Phxlog.Blogs
  alias Phxlog.Blogs.Blog
  alias Phxlog.Blogs.Comment
  import Phxlog.AccountsFixtures
  import Phxlog.BlogsFixtures
  import Phxlog.CommentFixtures

  # ── Blogs ─────────────────────────────────────────────────────────────────────

  describe "list_blogs/0" do
    test "returns all blogs" do
      blog = blog_fixture()
      assert Enum.any?(Blogs.list_blogs(), &(&1.id == blog.id))
    end
  end

  describe "filter_blogs/1" do
    test "returns all blogs with empty query" do
      blog = blog_fixture()
      {blogs, _meta} = Blogs.filter_blogs(%{"q" => "", "page" => "1", "page_size" => "10"})
      assert Enum.any?(blogs, &(&1.id == blog.id))
    end

    test "filters blogs by title" do
      blog = blog_fixture(%{title: "Unique Elixir Title XYZ"})
      _other = blog_fixture(%{title: "Something Else"})

      {blogs, _meta} =
        Blogs.filter_blogs(%{
          "q" => "Unique Elixir Title XYZ",
          "page" => "1",
          "page_size" => "10"
        })

      assert length(blogs) == 1
      assert hd(blogs).id == blog.id
    end

    test "filters blogs by content" do
      blog = blog_fixture(%{content: "Unique content string ABC"})
      _other = blog_fixture()

      {blogs, _meta} =
        Blogs.filter_blogs(%{
          "q" => "Unique content string ABC",
          "page" => "1",
          "page_size" => "10"
        })

      assert Enum.any?(blogs, &(&1.id == blog.id))
    end

    test "returns empty list when no match" do
      {blogs, _meta} =
        Blogs.filter_blogs(%{"q" => "zzznomatch999", "page" => "1", "page_size" => "10"})

      assert blogs == []
    end
  end

  describe "get_blog!/1" do
    test "returns blog by id" do
      blog = blog_fixture()
      assert Blogs.get_blog!(blog.id).id == blog.id
    end

    test "raises when blog not found" do
      assert_raise Ecto.NoResultsError, fn ->
        Blogs.get_blog!(0)
      end
    end
  end

  describe "create_blog/1" do
    test "creates blog with valid attrs" do
      user = user_fixture()

      attrs = %{
        title: "New Blog",
        content: "Content",
        image_path: "https://example.com/img.jpg",
        user_id: user.id
      }

      assert {:ok, %Blog{} = blog} = Blogs.create_blog(attrs)
      assert blog.title == "New Blog"
    end

    test "returns error with invalid attrs" do
      assert {:error, changeset} = Blogs.create_blog(%{})
      assert changeset.errors[:title]
    end

    test "broadcasts :blog_created" do
      Blogs.subscribe()
      user = user_fixture()

      attrs = %{
        title: "Broadcast Blog",
        content: "Content",
        image_path: "https://example.com/img.jpg",
        user_id: user.id
      }

      {:ok, blog} = Blogs.create_blog(attrs)
      assert_receive {:blog_created, ^blog}
    end
  end

  describe "update_blog/2" do
    test "updates blog with valid attrs" do
      blog = blog_fixture()
      assert {:ok, updated} = Blogs.update_blog(blog, %{title: "Updated Title"})
      assert updated.title == "Updated Title"
    end

    test "returns error with invalid attrs" do
      blog = blog_fixture()
      assert {:error, changeset} = Blogs.update_blog(blog, %{title: nil})
      assert changeset.errors[:title]
    end

    test "broadcasts :blog_updated" do
      blog = blog_fixture()
      Blogs.subscribe()
      {:ok, _} = Blogs.update_blog(blog, %{title: "Updated"})
      assert_receive {:blog_updated, _}
    end
  end

  describe "delete_blog/1" do
    test "deletes the blog" do
      blog = blog_fixture()
      assert {:ok, _} = Blogs.delete_blog(blog)
      assert_raise Ecto.NoResultsError, fn -> Blogs.get_blog!(blog.id) end
    end

    test "broadcasts :blog_deleted" do
      blog = blog_fixture()
      Blogs.subscribe()
      {:ok, _} = Blogs.delete_blog(blog)
      assert_receive {:blog_deleted, _}
    end
  end

  describe "featured_blogs/1" do
    test "returns up to 3 blogs excluding the given blog" do
      blog = blog_fixture()
      Enum.each(1..3, fn _ -> blog_fixture() end)
      featured = Blogs.featured_blogs(blog)
      assert length(featured) <= 3
      refute Enum.any?(featured, &(&1.id == blog.id))
    end
  end

  describe "change_blog/2" do
    test "returns a changeset" do
      blog = blog_fixture()
      assert %Ecto.Changeset{} = Blogs.change_blog(blog)
    end
  end

  # ── Comments ──────────────────────────────────────────────────────────────────

  describe "list_comments/2" do
    test "returns paginated comments for a blog" do
      user = user_fixture()
      scope = user_scope_fixture(user)
      blog = blog_fixture()
      Enum.each(1..7, fn i -> comment_fixture(scope, blog, %{"content" => "Comment #{i}"}) end)
      {comments, has_more} = Blogs.list_comments(blog, page: 1, per_page: 5)
      assert length(comments) == 5
      assert has_more == true
    end

    test "returns has_more false on last page" do
      user = user_fixture()
      scope = user_scope_fixture(user)
      blog = blog_fixture()
      Enum.each(1..3, fn i -> comment_fixture(scope, blog, %{"content" => "Comment #{i}"}) end)
      {comments, has_more} = Blogs.list_comments(blog, page: 1, per_page: 5)
      assert length(comments) == 3
      assert has_more == false
    end

    test "returns only comments for the given blog" do
      user = user_fixture()
      scope = user_scope_fixture(user)
      blog1 = blog_fixture()
      blog2 = blog_fixture()
      comment_fixture(scope, blog1, %{"content" => "Blog 1 comment"})
      comment_fixture(scope, blog2, %{"content" => "Blog 2 comment"})
      {comments, _} = Blogs.list_comments(blog1, page: 1, per_page: 10)
      assert Enum.all?(comments, &(&1.blog_id == blog1.id))
    end
  end

  describe "create_comment/3" do
    test "creates comment with valid attrs" do
      user = user_fixture()
      scope = user_scope_fixture(user)
      blog = blog_fixture()

      assert {:ok, %Comment{} = comment} =
               Blogs.create_comment(scope, blog, %{"content" => "Great post!"})

      assert comment.content == "Great post!"
      assert comment.blog_id == blog.id
      assert comment.user_id == user.id
    end

    test "returns error with blank content" do
      user = user_fixture()
      scope = user_scope_fixture(user)
      blog = blog_fixture()
      assert {:error, changeset} = Blogs.create_comment(scope, blog, %{"content" => ""})
      assert changeset.errors[:content]
    end

    test "broadcasts :created" do
      user = user_fixture()
      scope = user_scope_fixture(user)
      blog = blog_fixture()
      Blogs.subscribe_comments(blog)
      {:ok, comment} = Blogs.create_comment(scope, blog, %{"content" => "Hello!"})
      assert_receive {:created, received_comment}
      assert received_comment.id == comment.id
    end
  end

  describe "update_comment/4" do
    test "updates comment with valid attrs" do
      user = user_fixture()
      scope = user_scope_fixture(user)
      blog = blog_fixture()
      comment = comment_fixture(scope, blog)

      assert {:ok, updated} =
               Blogs.update_comment(scope, blog, comment, %{"content" => "Updated!"})

      assert updated.content == "Updated!"
    end

    test "raises when user is not the author" do
      user1 = user_fixture()
      user2 = user_fixture()
      scope1 = user_scope_fixture(user1)
      scope2 = user_scope_fixture(user2)
      blog = blog_fixture()
      comment = comment_fixture(scope1, blog)

      assert_raise MatchError, fn ->
        Blogs.update_comment(scope2, blog, comment, %{"content" => "Hacked!"})
      end
    end

    test "broadcasts :updated" do
      user = user_fixture()
      scope = user_scope_fixture(user)
      blog = blog_fixture()
      comment = comment_fixture(scope, blog)
      Blogs.subscribe_comments(blog)
      {:ok, _} = Blogs.update_comment(scope, blog, comment, %{"content" => "Updated!"})
      assert_receive {:updated, _}
    end
  end

  describe "delete_comment/3" do
    test "deletes the comment" do
      user = user_fixture()
      scope = user_scope_fixture(user)
      blog = blog_fixture()
      comment = comment_fixture(scope, blog)
      assert {:ok, _} = Blogs.delete_comment(scope, blog, comment)
      {comments, _} = Blogs.list_comments(blog, page: 1, per_page: 10)
      refute Enum.any?(comments, &(&1.id == comment.id))
    end

    test "raises when user is not the author" do
      user1 = user_fixture()
      user2 = user_fixture()
      scope1 = user_scope_fixture(user1)
      scope2 = user_scope_fixture(user2)
      blog = blog_fixture()
      comment = comment_fixture(scope1, blog)

      assert_raise MatchError, fn ->
        Blogs.delete_comment(scope2, blog, comment)
      end
    end

    test "broadcasts :deleted" do
      user = user_fixture()
      scope = user_scope_fixture(user)
      blog = blog_fixture()
      comment = comment_fixture(scope, blog)
      Blogs.subscribe_comments(blog)
      {:ok, _} = Blogs.delete_comment(scope, blog, comment)
      assert_receive {:deleted, _}
    end
  end

  describe "change_comment/3" do
    test "returns a changeset" do
      user = user_fixture()
      scope = user_scope_fixture(user)
      assert %Ecto.Changeset{} = Blogs.change_comment(scope, %Comment{})
    end
  end

  # ── Likes ─────────────────────────────────────────────────────────────────────

  describe "liked_by_user?/2" do
    test "returns false when scope is nil" do
      blog = blog_fixture()
      assert Blogs.liked_by_user?(blog, nil) == false
    end

    test "returns false when user has not liked" do
      user = user_fixture()
      scope = user_scope_fixture(user)
      blog = blog_fixture()
      assert Blogs.liked_by_user?(blog, scope) == false
    end

    test "returns true when user has liked" do
      user = user_fixture()
      scope = user_scope_fixture(user)
      blog = blog_fixture()
      Blogs.toggle_like(scope, blog)
      assert Blogs.liked_by_user?(blog, scope) == true
    end
  end

  describe "likes_count/1" do
    test "returns 0 when no likes" do
      blog = blog_fixture()
      assert Blogs.likes_count(blog) == 0
    end

    test "returns correct count" do
      blog = blog_fixture()
      Blogs.toggle_like(user_scope_fixture(user_fixture()), blog)
      Blogs.toggle_like(user_scope_fixture(user_fixture()), blog)
      assert Blogs.likes_count(blog) == 2
    end
  end

  describe "toggle_like/2" do
    test "creates a like when not yet liked" do
      user = user_fixture()
      scope = user_scope_fixture(user)
      blog = blog_fixture()
      Blogs.toggle_like(scope, blog)
      assert Blogs.liked_by_user?(blog, scope) == true
    end

    test "removes a like when already liked" do
      user = user_fixture()
      scope = user_scope_fixture(user)
      blog = blog_fixture()
      Blogs.toggle_like(scope, blog)
      Blogs.toggle_like(scope, blog)
      assert Blogs.liked_by_user?(blog, scope) == false
    end

    test "increments count on like" do
      user = user_fixture()
      scope = user_scope_fixture(user)
      blog = blog_fixture()
      Blogs.toggle_like(scope, blog)
      assert Blogs.likes_count(blog) == 1
    end

    test "decrements count on unlike" do
      user = user_fixture()
      scope = user_scope_fixture(user)
      blog = blog_fixture()
      Blogs.toggle_like(scope, blog)
      Blogs.toggle_like(scope, blog)
      assert Blogs.likes_count(blog) == 0
    end

    test "broadcasts :likes_updated" do
      user = user_fixture()
      scope = user_scope_fixture(user)
      blog = blog_fixture()
      Blogs.subscribe(blog.id)
      Blogs.toggle_like(scope, blog)
      assert_receive {:likes_updated, 1}
    end

    test "different users can like the same blog" do
      blog = blog_fixture()
      Blogs.toggle_like(user_scope_fixture(user_fixture()), blog)
      Blogs.toggle_like(user_scope_fixture(user_fixture()), blog)
      assert Blogs.likes_count(blog) == 2
    end
  end

  # ── PubSub ────────────────────────────────────────────────────────────────────

  describe "subscribe/0 and subscribe/1" do
    test "subscribe/0 receives blog-level broadcasts" do
      Blogs.subscribe()
      user = user_fixture()

      attrs = %{
        title: "PubSub Test",
        content: "Content",
        image_path: "https://example.com/img.jpg",
        user_id: user.id
      }

      {:ok, blog} = Blogs.create_blog(attrs)
      assert_receive {:blog_created, ^blog}
    end

    test "subscribe/1 receives blog-specific broadcasts" do
      blog = blog_fixture()
      Blogs.subscribe(blog.id)
      {:ok, _} = Blogs.update_blog(blog, %{title: "Updated"})
      assert_receive {:blog_updated, _}
    end
  end
end
