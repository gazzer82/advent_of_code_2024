defmodule Aoc2024.MixProject do
  use Mix.Project

  def project do
    [
      app: :aoc_2024,
      version: "0.1.0",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :wx, :observer]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
      {:aoc, "~> 0.13"},
      {:memoized, "~> 0.1.0"},
      {:nimble_parsec, "~> 1.4"},
      {:arrays, "~> 2.1"},
      {:fun_land, "~> 0.10.0"},
      {:arrays_aja, "~> 0.2.0"}
    ]
  end

  def cli do
    [
      preferred_envs: ["aoc.test": :test]
    ]
  end
end
