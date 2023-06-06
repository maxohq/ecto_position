defmodule EctoPosition.MixProject do
  use Mix.Project

  def project do
    [
      app: :ecto_position,
      version: "0.3.0",
      description: "Manage a position field in an Ecto schema",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
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

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ecto, "~> 3.0"},
      {:ex_doc, ">= 0.0.0", only: :dev}
    ]
  end
end
