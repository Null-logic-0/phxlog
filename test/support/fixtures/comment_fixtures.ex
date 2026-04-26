defmodule Phxlog.CommentFixtures do
  alias Phxlog.Blogs

  def comment_fixture(scope, blog, attrs \\ %{}) do
    attrs = Enum.into(attrs, %{"content" => "Test comment"})
    {:ok, comment} = Blogs.create_comment(scope, blog, attrs)
    comment
  end
end
