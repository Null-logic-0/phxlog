defmodule Phxlog.Repo.Migrations.CreateLikes do
  use Ecto.Migration

  def change do
    create table(:likes) do
      add :blog_id, references(:blogs, on_delete: :delete_all)
      add :user_id, references(:users, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create unique_index(:likes, [:blog_id, :user_id])
    create index(:likes, [:blog_id])
  end
end
