defmodule Phxlog.Blogs.Like do
  use Ecto.Schema
  import Ecto.Changeset

  schema "likes" do
    belongs_to :blog, Phxlog.Blogs.Blog
    belongs_to :user, Phxlog.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(like, attrs, scope) do
    like
    |> cast(attrs, [:blog_id])
    |> validate_required([:blog_id])
    |> put_change(:user_id, scope.user.id)
    |> unique_constraint([:blog_id, :user_id])
  end
end
