defmodule EctoPosition.Repo.Migrations.AddTestTable do
  use Ecto.Migration

  def change do
    execute("CREATE SCHEMA IF NOT EXISTS other_prefix")

    for prefix <- ["public", "other_prefix"] do
      create table(:todos, prefix: prefix) do
        add :name, :string
        add :category, :string
        add :position, :integer
        timestamps()
      end

      flush()
    end
  end
end
