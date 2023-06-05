defmodule EctoPosition do
  import Ecto.Query

  def add(repo, %type{} = struct, at_position, opts \\ []) do
    {scope, repo_opts} = Keyword.pop(opts, :scope, type)

    with {:ok, position_to_add} <-
           calculate_position(repo, scope, struct, at_position, repo_opts),
         {:ok, _struct} <-
           increment_positions_for_added_position(repo, scope, struct, position_to_add, repo_opts) do
      set_new_position(repo, scope, struct, position_to_add, repo_opts)
    end
  end

  def move(repo, %type{} = struct, at_position, opts \\ []) do
    {scope, repo_opts} = Keyword.pop(opts, :scope, type)

    with {:ok, new_position} <-
           calculate_position(repo, scope, struct, at_position, repo_opts),
         {:ok, _struct} <-
           decrement_positions_for_changed_position(repo, scope, struct, new_position, repo_opts),
         {:ok, _struct} <-
           increment_positions_for_changed_position(repo, scope, struct, new_position, repo_opts) do
      set_new_position(repo, scope, struct, new_position, repo_opts)
    end
  end

  def remove(repo, %type{} = struct, opts \\ []) do
    {scope, repo_opts} = Keyword.pop(opts, :scope, type)

    decrement_positions_for_removed_position(repo, scope, struct, repo_opts)
  end

  # Get the old position of the record we are repositioning.
  defp get_old_position_query(scope, struct) do
    from(record in scope, where: record.id == ^struct.id, select: record.position)
  end

  # If the desired position is less than the count of all records, then we
  # return that position. Otherwise, we return the count of all records minus
  # one (because of 0-based index).
  defp calculate_position(repo, scope, _struct, at_position, repo_opts)
       when is_integer(at_position) do
    case repo.one(from(t in scope, select: count(t.id)), repo_opts) do
      count when at_position < count -> {:ok, at_position}
      count -> {:ok, count - 1}
    end
  end

  # If the desired position is `:top`, then we return 0.
  defp calculate_position(_repo, _query, _struct, :top, _repo_opts) do
    {:ok, 0}
  end

  # If the desired position is `:bottom`, then we return the bottom position based
  # upon existing count.
  defp calculate_position(repo, scope, _struct, :bottom, repo_opts) do
    count = repo.one(from(t in scope, select: count(t.id)), repo_opts)
    {:ok, count - 1}
  end

  # If the desired position is `:up`, then we return the old position - 1 or 0
  # if already at the top.
  defp calculate_position(repo, scope, struct, :up, repo_opts) do
    old_position_query = get_old_position_query(scope, struct)

    case repo.one(old_position_query, repo_opts) do
      0 -> {:ok, 0}
      count -> {:ok, count - 1}
    end
  end

  # If the desired position is `:down`, then we return the old position + 1 or
  # the bottom position if already at the bottom.
  defp calculate_position(repo, scope, struct, :down, repo_opts) do
    old_position_query = get_old_position_query(scope, struct)

    with old_position <- repo.one(old_position_query, repo_opts),
         count <- repo.one(from(t in scope, select: count(t.id)), repo_opts) do
      bottom_position = count - 1

      if old_position >= bottom_position do
        {:ok, bottom_position}
      else
        {:ok, old_position + 1}
      end
    end
  end

  # Decrement the position of all records that are greater than the old
  # position.
  defp decrement_positions_for_removed_position(repo, scope, struct, repo_opts) do
    old_position_query = get_old_position_query(scope, struct)

    repo.update_all(
      from(record in scope,
        where: record.position > subquery(old_position_query),
        update: [inc: [position: -1]]
      ),
      [],
      repo_opts
    )

    {:ok, struct}
  end

  # Decrement the position of all records that are greater than the old
  # position, but less than or equal to the new position.
  defp decrement_positions_for_changed_position(repo, scope, struct, new_position, repo_opts) do
    old_position_query = get_old_position_query(scope, struct)

    repo.update_all(
      from(t in scope,
        where: t.id != ^struct.id,
        where: t.position > subquery(old_position_query) and t.position <= ^new_position,
        update: [inc: [position: -1]]
      ),
      [],
      repo_opts
    )

    {:ok, struct}
  end

  # Increments the position of all records that are greater than or equal to the
  # position being added.
  defp increment_positions_for_added_position(repo, scope, struct, new_position, repo_opts) do
    repo.update_all(
      from(t in scope,
        where: t.id != ^struct.id,
        where: t.position >= ^new_position,
        update: [inc: [position: 1]]
      ),
      [],
      repo_opts
    )

    {:ok, struct}
  end

  # Increments the position of all records that are less than the old
  # position, but greater than or equal to the new position.
  defp increment_positions_for_changed_position(repo, scope, struct, new_position, repo_opts) do
    old_position_query = get_old_position_query(scope, struct)

    repo.update_all(
      from(t in scope,
        where: t.id != ^struct.id,
        where: t.position < subquery(old_position_query) and t.position >= ^new_position,
        update: [inc: [position: 1]]
      ),
      [],
      repo_opts
    )

    {:ok, struct}
  end

  # Update the position of the record we are repositioning.
  defp set_new_position(repo, scope, struct, new_position, repo_opts) do
    repo.update_all(
      from(t in scope,
        where: t.id == ^struct.id,
        update: [set: [position: ^new_position]]
      ),
      [],
      repo_opts
    )

    {:ok, new_position}
  end
end
