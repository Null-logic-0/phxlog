defmodule Phxlog.Repo.Migrations.CreateBlogs do
  use Ecto.Migration

  def change do
    create table(:blogs) do
      add :title, :string
      add :content, :text
      add :image_path, :string

      timestamps(type: :utc_datetime)
    end
  end
end
