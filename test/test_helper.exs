ExUnit.start()

defmodule EctoPosition.TestCase do
  use ExUnit.CaseTemplate

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(EctoPosition.Test.Repo)
    Ecto.Adapters.SQL.Sandbox.mode(EctoPosition.Test.Repo, {:shared, self()})
  end
end

{:ok, _pid} = EctoPosition.Test.Repo.start_link()
Ecto.Adapters.SQL.Sandbox.mode(EctoPosition.Test.Repo, {:shared, self()})
