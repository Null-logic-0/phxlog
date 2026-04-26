defmodule Phxlog.BlogsFixtures do
  import Phxlog.AccountsFixtures
  alias Phxlog.Blogs

  def blog_fixture(attrs \\ %{}) do
    user = user_fixture()

    attrs =
      Enum.into(attrs, %{
        title: "Test Blog #{System.unique_integer()}",
        content: "Some content",
        image_path: "https://example.com/image.jpg",
        user_id: user.id
      })

    {:ok, blog} = Blogs.create_blog(attrs)
    blog
  end
end
