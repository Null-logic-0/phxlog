defmodule Phxlog.BlogsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Phxlog.Blogs` context.
  """

  @doc """
  Generate a blog.
  """
  def blog_fixture(attrs \\ %{}) do
    {:ok, blog} =
      attrs
      |> Enum.into(%{
        content: "some content",
        image_path: "some image_path",
        title: "some title"
      })
      |> Phxlog.Blogs.create_blog()

    blog
  end
end
