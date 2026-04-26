defmodule Phxlog.Blogs.Blog do
  use Ecto.Schema
  import Ecto.Changeset

  schema "blogs" do
    field :title, :string
    field :content, :string
    field :image_path, :string

    has_many :comments, Phxlog.Blogs.Comment
    has_many :likes, Phxlog.Blogs.Like

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(blog, attrs) do
    blog
    |> cast(attrs, [:title, :content, :image_path])
    |> validate_required([:title, :content])
    |> validate_length(:title, min: 3, max: 70)
    |> validate_length(:content, max: 500)
  end
end
