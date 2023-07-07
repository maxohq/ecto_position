defmodule EctoPosition.MixProject do
  use Mix.Project

  def project do
    [
      app: :ecto_position,
      version: "0.5.0",
      description: "Manage a position field in an Ecto schema",
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),
      package: package(),
      docs: docs()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  def docs do
    [
      main: "EctoPosition",
      source_url_pattern:
        "https://github.com/baldwindavid/ecto_position/blob/main/%{path}#L%{line}"
    ]
  end

  def package do
    [
      maintainers: ["David Baldwin"],
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => "https://github.com/baldwindavid/ecto_position"},
      files: ~w(mix.exs README.md lib)
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp aliases do
    [test: ["ecto.create --quiet", "ecto.migrate", "test"]]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ecto_sql, ">= 3.0.0"},
      {:postgrex, ">= 0.0.0"},
      {:ex_doc, ">= 0.0.0", only: :dev}
    ]
  end
end
