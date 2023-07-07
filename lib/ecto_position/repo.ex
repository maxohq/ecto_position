defmodule EctoPosition.Repo do
  use Ecto.Repo,
    otp_app: :ecto_position,
    adapter: Ecto.Adapters.Postgres
end
