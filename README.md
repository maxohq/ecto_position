# EctoPosition

[![Hex.pm](https://img.shields.io/hexpm/v/ecto_position.svg)](https://hex.pm/packages/ecto_position)
[![Documentation](https://img.shields.io/badge/docs-hexpm-blue.svg)](https://hexdocs.pm/ecto_position)

A powerful Elixir package for managing position fields in Ecto schemas. Easily add drag-and-drop ordering, list reordering, and position management to your Phoenix applications.

## ✨ Features

- 🎯 **Precise Positioning** - Insert records at specific positions with automatic repositioning
- 🔄 **Flexible Movement** - Move records up, down, to top, bottom, or relative to other records
- 🎌 **Scoped Operations** - Limit positioning operations to specific query scopes
- 🗂️ **Multi-tenant Support** - Full database prefix support for multi-tenant applications
- 🔧 **Automatic Cleanup** - Smart repositioning when removing records
- 🔄 **Position Reset** - Bulk reset positions for data cleanup

## 🚀 Installation

Add `ecto_position` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ecto_position, "~> 0.5.0"}
  ]
end
```

## 📖 Usage

### Adding Records with Position

```elixir
# Add at specific position (repositions existing records)
{:ok, todo} = EctoPosition.add(Repo, new_todo, 1)

# Add at top (position 0)
{:ok, todo} = EctoPosition.add(Repo, new_todo, :top)

# Add at bottom (last position)
{:ok, todo} = EctoPosition.add(Repo, new_todo, :bottom)

# Add relative to another record
{:ok, todo} = EctoPosition.add(Repo, new_todo, {:above, existing_todo})
{:ok, todo} = EctoPosition.add(Repo, new_todo, {:below, existing_todo})
```

### Moving Records

```elixir
# Move to specific position
{:ok, todo} = EctoPosition.move(Repo, todo, 2)

# Move up/down one position
{:ok, todo} = EctoPosition.move(Repo, todo, :up)
{:ok, todo} = EctoPosition.move(Repo, todo, :down)

# Move to top/bottom
{:ok, todo} = EctoPosition.move(Repo, todo, :top)
{:ok, todo} = EctoPosition.move(Repo, todo, :bottom)

# Move relative to another record
{:ok, todo} = EctoPosition.move(Repo, todo, {:above, other_todo})
{:ok, todo} = EctoPosition.move(Repo, todo, {:below, other_todo})
```

### Removing Records

```elixir
# Remove and reposition remaining records
{:ok, todo} = EctoPosition.remove(Repo, todo)
Repo.delete(todo)
```

### Resetting Positions

```elixir
# Reset all positions in order (useful for data cleanup)
{:ok, todos} = EctoPosition.reset(Repo, Todo)
```

## 🎯 Scoped Operations

Limit operations to specific subsets of records:

```elixir
# Only affect todos in a specific category
scope = from(t in Todo, where: t.category == ^"Work")

{:ok, todo} = EctoPosition.add(Repo, new_todo, :top, scope: scope)
{:ok, todo} = EctoPosition.move(Repo, todo, :bottom, scope: scope)
{:ok, todo} = EctoPosition.remove(Repo, todo, scope: scope)
{:ok, todos} = EctoPosition.reset(Repo, scope)
```

## 🏢 Multi-tenant Support

Works seamlessly with database prefixes:

```elixir
# Operations automatically respect the record's prefix
{:ok, todo} = EctoPosition.add(Repo, tenant_todo, :top)
{:ok, todo} = EctoPosition.move(Repo, tenant_todo, :bottom)
```

## 🔧 Position Options

| Option | Description | Example |
|--------|-------------|---------|
| `Integer` | Specific position (0-based) | `0`, `1`, `5` |
| `:top` | Move to first position | `:top` |
| `:bottom` | Move to last position | `:bottom` |
| `:up` | Move up one position | `:up` |
| `:down` | Move down one position | `:down` |
| `{:above, record}` | Position above another record | `{:above, todo}` |
| `{:below, record}` | Position below another record | `{:below, todo}` |

## 🎪 Smart Behavior

- **Negative positions** are automatically set to 0
- **Positions beyond range** are set to the last position
- **Edge case handling** - moving up from top or down from bottom is safe
- **Automatic repositioning** - other records adjust automatically
- **Nil record handling** - `{:above, nil}` moves to top, `{:below, nil}` moves to bottom

## 📚 API Reference

### Core Functions

- `EctoPosition.add(repo, record, position, opts \\ [])` - Add record at position
- `EctoPosition.move(repo, record, position, opts \\ [])` - Move existing record
- `EctoPosition.remove(repo, record, opts \\ [])` - Remove record and reposition others
- `EctoPosition.reset(repo, queryable, opts \\ [])` - Reset all positions

### Options

- `:scope` - Limit operations to a specific query scope
- Database prefixes are automatically handled

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is licensed under the MIT License.

---

Made with ❤️ for the Elixir community
