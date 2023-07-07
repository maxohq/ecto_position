defmodule EctoPosition.Todo do
  use Ecto.Schema

  schema "todos" do
    field :name, :string
    field :category, :string
    field :position, :integer
    timestamps()
  end
end
