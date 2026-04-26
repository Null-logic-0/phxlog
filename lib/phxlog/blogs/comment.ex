defmodule Phxlog.Blogs.Comment do
  use Ecto.Schema
  import Ecto.Changeset

  schema "comments" do
    field :content, :string

    belongs_to :blog, Phxlog.Blogs.Blog
    belongs_to :user, Phxlog.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(comment, attrs, user_scope) do
    comment
    |> cast(attrs, [:content,])
    |> validate_required([:content])
    |> validate_length(:content, max: 200)
    |> put_assoc(:user, user_scope.user)
  end
end
