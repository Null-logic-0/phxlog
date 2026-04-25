defmodule Phxlog.Blogs.Blog do
  use Ecto.Schema
  import Ecto.Changeset

  schema "blogs" do
    field :title, :string
    field :content, :string
    field :image_path, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(blog, attrs) do
    blog
    |> cast(attrs, [:title, :content, :image_path])
    |> validate_required([:title, :content, :image_path])
    |> validate_length(:title, min: 3, max: 70)
    |> validate_length(:content, max: 500)
  end
end
