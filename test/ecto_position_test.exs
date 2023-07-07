defmodule EctoPositionTest do
  use EctoPosition.TestCase

  import Ecto.Query

  alias EctoPosition.Test.Repo
  alias EctoPosition.Todo

  describe "add/4" do
    test "position of 0, repositions lower records" do
      [
        %{id: first_todo_id, position: 0},
        %{id: last_todo_id, position: 1}
      ] = insert_todos(2)

      %{id: new_todo_id} = new_todo = insert_todo()

      assert {:ok, %{position: 0}} = EctoPosition.add(Repo, new_todo, 0)

      assert [
               %{id: ^new_todo_id, position: 0},
               %{id: ^first_todo_id, position: 1},
               %{id: ^last_todo_id, position: 2}
             ] = Repo.all(from Todo, order_by: :position)
    end

    test "position of 1 between records, repositions lower records" do
      [
        %{id: first_todo_id, position: 0},
        %{id: last_todo_id, position: 1}
      ] = insert_todos(2)

      %{id: new_todo_id} = new_todo = insert_todo()

      assert {:ok, %{position: 1}} = EctoPosition.add(Repo, new_todo, 1)

      assert [
               %{id: ^first_todo_id, position: 0},
               %{id: ^new_todo_id, position: 1},
               %{id: ^last_todo_id, position: 2}
             ] = Repo.all(from Todo, order_by: :position)
    end

    test "position of 2 when two records exist will not update existing positions" do
      [
        %{id: first_todo_id, position: 0},
        %{id: last_todo_id, position: 1}
      ] = insert_todos(2)

      %{id: new_todo_id} = new_todo = insert_todo()

      assert {:ok, %{position: 2}} = EctoPosition.add(Repo, new_todo, 2)

      assert [
               %{id: ^first_todo_id, position: 0},
               %{id: ^last_todo_id, position: 1},
               %{id: ^new_todo_id, position: 2}
             ] = Repo.all(from Todo, order_by: :position)
    end

    test "a negative position will be set to 0" do
      new_todo = insert_todo()
      assert {:ok, %{position: 0}} = EctoPosition.add(Repo, new_todo, -100)
    end

    test "position greater than the number of records will be set to the bottom position" do
      insert_todos(2)

      new_todo = insert_todo()

      assert {:ok, %{position: 2}} = EctoPosition.add(Repo, new_todo, 100)
    end

    test "position of :top will be set to 0 and reposition lower records" do
      [
        %{id: first_todo_id, position: 0},
        %{id: last_todo_id, position: 1}
      ] = insert_todos(2)

      %{id: new_todo_id} = new_todo = insert_todo()
      assert {:ok, %{position: 0}} = EctoPosition.add(Repo, new_todo, :top)

      assert [
               %{id: ^new_todo_id, position: 0},
               %{id: ^first_todo_id, position: 1},
               %{id: ^last_todo_id, position: 2}
             ] = Repo.all(from Todo, order_by: :position)
    end

    test "position of :bottom will be set to the bottom and not reposition other records" do
      [
        %{id: first_todo_id, position: 0},
        %{id: last_todo_id, position: 1}
      ] = insert_todos(2)

      %{id: new_todo_id} = new_todo = insert_todo()
      assert {:ok, %{position: 2}} = EctoPosition.add(Repo, new_todo, :bottom)

      assert [
               %{id: ^first_todo_id, position: 0},
               %{id: ^last_todo_id, position: 1},
               %{id: ^new_todo_id, position: 2}
             ] = Repo.all(from Todo, order_by: :position)
    end

    test "positioning :above a record, repositions lower records" do
      [
        %{id: first_todo_id, position: 0} = first_todo,
        %{id: last_todo_id, position: 1}
      ] = insert_todos(2)

      %{id: new_todo_id} = new_todo = insert_todo()

      assert {:ok, %{position: 0}} = EctoPosition.add(Repo, new_todo, {:above, first_todo})

      assert [
               %{id: ^new_todo_id, position: 0},
               %{id: ^first_todo_id, position: 1},
               %{id: ^last_todo_id, position: 2}
             ] = Repo.all(from Todo, order_by: :position)
    end

    test "positioning :below a record, repositions lower records" do
      [
        %{id: first_todo_id, position: 0} = first_todo,
        %{id: last_todo_id, position: 1}
      ] = insert_todos(2)

      %{id: new_todo_id} = new_todo = insert_todo()

      assert {:ok, %{position: 1}} = EctoPosition.add(Repo, new_todo, {:below, first_todo})

      assert [
               %{id: ^first_todo_id, position: 0},
               %{id: ^new_todo_id, position: 1},
               %{id: ^last_todo_id, position: 2}
             ] = Repo.all(from Todo, order_by: :position)
    end

    test "can be scoped to a query" do
      scope = from(t in Todo, where: t.category == ^"This Category")

      [
        %{id: first_todo_id, position: 0},
        %{id: last_todo_id, position: 1}
      ] = insert_todos(2, category: "This Category")

      [
        %{id: other_category_first_todo_id, position: 0},
        %{id: other_category_last_todo_id, position: 1}
      ] = insert_todos(2, category: "Other Category")

      %{id: new_todo_id} = new_todo = insert_todo(category: "This Category")

      assert {:ok, %{position: 0}} = EctoPosition.add(Repo, new_todo, :top, scope: scope)

      assert [
               %{id: ^new_todo_id, position: 0},
               %{id: ^first_todo_id, position: 1},
               %{id: ^last_todo_id, position: 2}
             ] = Repo.all(from scope, order_by: :position)

      assert [
               %{id: ^other_category_first_todo_id, position: 0},
               %{id: ^other_category_last_todo_id, position: 1}
             ] =
               Repo.all(
                 from t in Todo, where: t.category == "Other Category", order_by: :position
               )
    end

    test "supports passing a database prefix" do
      [
        %{id: first_todo_id, position: 0},
        %{id: last_todo_id, position: 1}
      ] = insert_todos(2)

      [
        %{id: other_prefix_first_todo_id, position: 0},
        %{id: other_prefix_last_todo_id, position: 1}
      ] = insert_todos(2, prefix: "other_prefix")

      %{id: new_todo_id} = new_todo = insert_todo()

      assert {:ok, %{position: 0}} = EctoPosition.add(Repo, new_todo, :top)

      assert [
               %{id: ^new_todo_id, position: 0},
               %{id: ^first_todo_id, position: 1},
               %{id: ^last_todo_id, position: 2}
             ] = Repo.all(from Todo, order_by: :position)

      assert [
               %{id: ^other_prefix_first_todo_id, position: 0},
               %{id: ^other_prefix_last_todo_id, position: 1}
             ] = Repo.all(from(Todo, order_by: :position), prefix: "other_prefix")
    end
  end

  describe "move/4" do
    test "reposition from 2 to 0, repositions lower records" do
      [
        %{id: first_todo_id, position: 0},
        %{id: middle_todo_id, position: 1},
        %{id: last_todo_id, position: 2} = last_todo
      ] = insert_todos(3)

      assert {:ok, %{position: 0}} = EctoPosition.move(Repo, last_todo, 0)

      assert [
               %{id: ^last_todo_id, position: 0},
               %{id: ^first_todo_id, position: 1},
               %{id: ^middle_todo_id, position: 2}
             ] = Repo.all(from Todo, order_by: :position)
    end

    test "reposition from 2 to 1 between records, repositions lower records" do
      [
        %{id: first_todo_id, position: 0},
        %{id: middle_todo_id, position: 1},
        %{id: last_todo_id, position: 2} = last_todo
      ] = insert_todos(3)

      assert {:ok, %{position: 1}} = EctoPosition.move(Repo, last_todo, 1)

      assert [
               %{id: ^first_todo_id, position: 0},
               %{id: ^last_todo_id, position: 1},
               %{id: ^middle_todo_id, position: 2}
             ] = Repo.all(from Todo, order_by: :position)
    end

    test "reposition from 0 to 2, repositions higher records" do
      [
        %{id: first_todo_id, position: 0} = first_todo,
        %{id: middle_todo_id, position: 1},
        %{id: last_todo_id, position: 2}
      ] = insert_todos(3)

      assert {:ok, %{position: 2}} = EctoPosition.move(Repo, first_todo, 2)

      assert [
               %{id: ^middle_todo_id, position: 0},
               %{id: ^last_todo_id, position: 1},
               %{id: ^first_todo_id, position: 2}
             ] = Repo.all(from Todo, order_by: :position)
    end

    test "reposition of :up will be set to the position above and reposition the record previously above" do
      [
        %{id: first_todo_id, position: 0},
        %{id: middle_todo_id, position: 1},
        %{id: last_todo_id, position: 2} = last_todo
      ] = insert_todos(3)

      assert {:ok, %{position: 1}} = EctoPosition.move(Repo, last_todo, :up)

      assert [
               %{id: ^first_todo_id, position: 0},
               %{id: ^last_todo_id, position: 1},
               %{id: ^middle_todo_id, position: 2}
             ] = Repo.all(from Todo, order_by: :position)
    end

    test "repositioning :up when already at the top results in no position changes" do
      [
        %{id: first_todo_id, position: 0} = first_todo,
        %{id: middle_todo_id, position: 1},
        %{id: last_todo_id, position: 2}
      ] = insert_todos(3)

      assert {:ok, %{position: 0}} = EctoPosition.move(Repo, first_todo, :up)

      assert [
               %{id: ^first_todo_id, position: 0},
               %{id: ^middle_todo_id, position: 1},
               %{id: ^last_todo_id, position: 2}
             ] = Repo.all(from Todo, order_by: :position)
    end

    test "reposition of :down will be set to the position below and reposition the record previously below" do
      [
        %{id: first_todo_id, position: 0} = first_todo,
        %{id: middle_todo_id, position: 1},
        %{id: last_todo_id, position: 2}
      ] = insert_todos(3)

      assert {:ok, %{position: 1}} = EctoPosition.move(Repo, first_todo, :down)

      assert [
               %{id: ^middle_todo_id, position: 0},
               %{id: ^first_todo_id, position: 1},
               %{id: ^last_todo_id, position: 2}
             ] = Repo.all(from Todo, order_by: :position)
    end

    test "repositioning :down when already at the bottom results in no position changes" do
      [
        %{id: first_todo_id, position: 0},
        %{id: middle_todo_id, position: 1},
        %{id: last_todo_id, position: 2} = last_todo
      ] = insert_todos(3)

      assert {:ok, %{position: 2}} = EctoPosition.move(Repo, last_todo, :down)

      assert [
               %{id: ^first_todo_id, position: 0},
               %{id: ^middle_todo_id, position: 1},
               %{id: ^last_todo_id, position: 2}
             ] = Repo.all(from Todo, order_by: :position)
    end

    test "reposition of :top will be set to 0 and reposition other records below" do
      [
        %{id: first_todo_id, position: 0},
        %{id: middle_todo_id, position: 1},
        %{id: last_todo_id, position: 2} = last_todo
      ] = insert_todos(3)

      assert {:ok, %{position: 0}} = EctoPosition.move(Repo, last_todo, :top)

      assert [
               %{id: ^last_todo_id, position: 0},
               %{id: ^first_todo_id, position: 1},
               %{id: ^middle_todo_id, position: 2}
             ] = Repo.all(from Todo, order_by: :position)
    end

    test "reposition of :bottom will be set to the bottom and reposition other records previously below" do
      [
        %{id: first_todo_id, position: 0} = first_todo,
        %{id: middle_todo_id, position: 1},
        %{id: last_todo_id, position: 2}
      ] = insert_todos(3)

      assert {:ok, %{position: 2}} = EctoPosition.move(Repo, first_todo, :bottom)

      assert [
               %{id: ^middle_todo_id, position: 0},
               %{id: ^last_todo_id, position: 1},
               %{id: ^first_todo_id, position: 2}
             ] = Repo.all(from Todo, order_by: :position)
    end

    test "repositioning :above a record, repositions the record previously above" do
      [
        %{id: first_todo_id, position: 0} = first_todo,
        %{id: middle_todo_id, position: 1},
        %{id: last_todo_id, position: 2} = last_todo
      ] = insert_todos(3)

      assert {:ok, %{position: 0}} = EctoPosition.move(Repo, last_todo, {:above, first_todo})

      assert [
               %{id: ^last_todo_id, position: 0},
               %{id: ^first_todo_id, position: 1},
               %{id: ^middle_todo_id, position: 2}
             ] = Repo.all(from Todo, order_by: :position)
    end

    test "repositioning :above a nil record will be set to the top" do
      [
        %{id: first_todo_id, position: 0},
        %{id: middle_todo_id, position: 1},
        %{id: last_todo_id, position: 2} = last_todo
      ] = insert_todos(3)

      assert {:ok, %{position: 0}} = EctoPosition.move(Repo, last_todo, {:above, nil})

      assert [
               %{id: ^last_todo_id, position: 0},
               %{id: ^first_todo_id, position: 1},
               %{id: ^middle_todo_id, position: 2}
             ] = Repo.all(from Todo, order_by: :position)
    end

    test "repositioning :below a record, repositions the record previously below" do
      [
        %{id: first_todo_id, position: 0} = first_todo,
        %{id: middle_todo_id, position: 1},
        %{id: last_todo_id, position: 2} = last_todo
      ] = insert_todos(3)

      assert {:ok, %{position: 2}} = EctoPosition.move(Repo, first_todo, {:below, last_todo})

      assert [
               %{id: ^middle_todo_id, position: 0},
               %{id: ^last_todo_id, position: 1},
               %{id: ^first_todo_id, position: 2}
             ] = Repo.all(from Todo, order_by: :position)
    end

    test "repositioning :below a nil record will be set to the bottom" do
      [
        %{id: first_todo_id, position: 0} = first_todo,
        %{id: middle_todo_id, position: 1},
        %{id: last_todo_id, position: 2}
      ] = insert_todos(3)

      assert {:ok, %{position: 2}} = EctoPosition.move(Repo, first_todo, {:below, nil})

      assert [
               %{id: ^middle_todo_id, position: 0},
               %{id: ^last_todo_id, position: 1},
               %{id: ^first_todo_id, position: 2}
             ] = Repo.all(from Todo, order_by: :position)
    end

    test "can be scoped to a query" do
      scope = from(t in Todo, where: t.category == ^"This Category")

      [
        %{id: first_todo_id, position: 0},
        %{id: middle_todo_id, position: 1},
        %{id: last_todo_id, position: 2} = last_todo
      ] = insert_todos(3, category: "This Category")

      [
        %{id: other_category_first_todo_id, position: 0},
        %{id: other_category_last_todo_id, position: 1}
      ] = insert_todos(2, category: "Other Category")

      assert {:ok, %{position: 0}} = EctoPosition.move(Repo, last_todo, :top, scope: scope)

      assert [
               %{id: ^last_todo_id, position: 0},
               %{id: ^first_todo_id, position: 1},
               %{id: ^middle_todo_id, position: 2}
             ] = Repo.all(from scope, order_by: :position)

      assert [
               %{id: ^other_category_first_todo_id, position: 0},
               %{id: ^other_category_last_todo_id, position: 1}
             ] =
               Repo.all(
                 from t in Todo, where: t.category == "Other Category", order_by: :position
               )
    end

    test "supports passing a database prefix" do
      [
        %{id: first_todo_id, position: 0},
        %{id: middle_todo_id, position: 1},
        %{id: last_todo_id, position: 2} = last_todo
      ] = insert_todos(3)

      [
        %{id: other_prefix_first_todo_id, position: 0},
        %{id: other_prefix_last_todo_id, position: 1}
      ] = insert_todos(2, prefix: "other_prefix")

      assert {:ok, %{position: 0}} = EctoPosition.move(Repo, last_todo, :top)

      assert [
               %{id: ^last_todo_id, position: 0},
               %{id: ^first_todo_id, position: 1},
               %{id: ^middle_todo_id, position: 2}
             ] = Repo.all(from Todo, order_by: :position)

      assert [
               %{id: ^other_prefix_first_todo_id, position: 0},
               %{id: ^other_prefix_last_todo_id, position: 1}
             ] = Repo.all(from(Todo, order_by: :position), prefix: "other_prefix")
    end
  end

  describe "remove/3" do
    test "repositions lower records one position higher" do
      [
        %{position: 0} = first_todo,
        %{id: middle_todo_id, position: 1},
        %{id: last_todo_id, position: 2}
      ] = insert_todos(3)

      assert {:ok, %{position: 0}} = EctoPosition.remove(Repo, first_todo)
      Repo.delete(first_todo)

      assert [
               %{id: ^middle_todo_id, position: 0},
               %{id: ^last_todo_id, position: 1}
             ] = Repo.all(from Todo, order_by: :position)
    end

    test "can be scoped to a query" do
      scope = from(t in Todo, where: t.category == ^"This Category")

      [
        %{position: 0} = first_todo,
        %{id: middle_todo_id, position: 1},
        %{id: last_todo_id, position: 2}
      ] = insert_todos(3, category: "This Category")

      [
        %{id: other_category_first_todo_id, position: 0},
        %{id: other_category_last_todo_id, position: 1}
      ] = insert_todos(2, category: "Other Category")

      assert {:ok, %{position: 0}} = EctoPosition.remove(Repo, first_todo, scope: scope)
      Repo.delete(first_todo)

      assert [
               %{id: ^middle_todo_id, position: 0},
               %{id: ^last_todo_id, position: 1}
             ] = Repo.all(from scope, order_by: :position)

      assert [
               %{id: ^other_category_first_todo_id, position: 0},
               %{id: ^other_category_last_todo_id, position: 1}
             ] =
               Repo.all(
                 from t in Todo, where: t.category == "Other Category", order_by: :position
               )
    end

    test "supports passing a database prefix" do
      [
        %{position: 0} = first_todo,
        %{id: middle_todo_id, position: 1},
        %{id: last_todo_id, position: 2}
      ] = insert_todos(3)

      [
        %{id: other_prefix_first_todo_id, position: 0},
        %{id: other_prefix_last_todo_id, position: 1}
      ] = insert_todos(2, prefix: "other_prefix")

      assert {:ok, %{position: 0}} = EctoPosition.remove(Repo, first_todo)
      Repo.delete(first_todo)

      assert [
               %{id: ^middle_todo_id, position: 0},
               %{id: ^last_todo_id, position: 1}
             ] = Repo.all(from Todo, order_by: :position)

      assert [
               %{id: ^other_prefix_first_todo_id, position: 0},
               %{id: ^other_prefix_last_todo_id, position: 1}
             ] = Repo.all(from(Todo, order_by: :position), prefix: "other_prefix")
    end
  end

  describe "harmonize_positions/3" do
    test "repositions records" do
      {:ok, %{id: first_todo_id}} = Repo.insert(%Todo{position: 100})
      {:ok, %{id: middle_todo_id}} = Repo.insert(%Todo{position: 300})
      {:ok, %{id: last_todo_id}} = Repo.insert(%Todo{position: 500})

      assert {:ok,
              [
                %{id: ^first_todo_id, position: 0},
                %{id: ^middle_todo_id, position: 1},
                %{id: ^last_todo_id, position: 2}
              ]} = EctoPosition.harmonize_positions(Repo, Todo)
    end

    test "can be scoped to a query" do
      scope = from(t in Todo, where: t.category == ^"This Category")

      {:ok, %{id: first_todo_id}} = Repo.insert(%Todo{position: 100, category: "This Category"})
      {:ok, %{id: middle_todo_id}} = Repo.insert(%Todo{position: 300, category: "This Category"})
      {:ok, %{id: last_todo_id}} = Repo.insert(%Todo{position: 500, category: "This Category"})

      [
        %{id: other_category_first_todo_id, position: 0},
        %{id: other_category_last_todo_id, position: 1}
      ] = insert_todos(2, category: "Other Category")

      assert {:ok,
              [
                %{id: ^first_todo_id, position: 0},
                %{id: ^middle_todo_id, position: 1},
                %{id: ^last_todo_id, position: 2}
              ]} = EctoPosition.harmonize_positions(Repo, scope)

      assert [
               %{id: ^other_category_first_todo_id, position: 0},
               %{id: ^other_category_last_todo_id, position: 1}
             ] =
               Repo.all(
                 from t in Todo, where: t.category == "Other Category", order_by: :position
               )
    end

    test "supports passing a database prefix" do
      {:ok, %{id: first_todo_id}} = Repo.insert(%Todo{position: 100})
      {:ok, %{id: middle_todo_id}} = Repo.insert(%Todo{position: 300})
      {:ok, %{id: last_todo_id}} = Repo.insert(%Todo{position: 500})

      {:ok, %{id: other_prefix_first_todo_id}} =
        Repo.insert(%Todo{position: 888}, prefix: "other_prefix")

      {:ok, %{id: other_prefix_last_todo_id}} =
        Repo.insert(%Todo{position: 999}, prefix: "other_prefix")

      assert {:ok,
              [
                %{id: ^first_todo_id, position: 0},
                %{id: ^middle_todo_id, position: 1},
                %{id: ^last_todo_id, position: 2}
              ]} = EctoPosition.harmonize_positions(Repo, Todo)

      assert [
               %{id: ^other_prefix_first_todo_id, position: 888},
               %{id: ^other_prefix_last_todo_id, position: 999}
             ] = Repo.all(from(Todo, order_by: :position), prefix: "other_prefix")
    end
  end

  def insert_todo(opts \\ []) do
    category = Keyword.get(opts, :category, "Default Category")
    prefix = Keyword.get(opts, :prefix, "public")

    {:ok, todo} =
      Repo.insert(
        %Todo{
          name: "New Todo",
          category: category
        },
        prefix: prefix
      )

    todo
  end

  def insert_todos(count, opts \\ []) do
    category = Keyword.get(opts, :category, "Default Category")
    prefix = Keyword.get(opts, :prefix, "public")

    Enum.map(0..(count - 1), fn position ->
      {:ok, todo} =
        Repo.insert(
          %Todo{
            name: "Todo #{position}",
            category: category,
            position: position
          },
          prefix: prefix
        )

      todo
    end)
  end
end
