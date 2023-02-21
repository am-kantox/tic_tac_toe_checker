defmodule TicTacToeChecker.MixProject do
  use Mix.Project

  def project do
    [
      app: :tic_tac_toe_checker,
      version: "0.1.0",
      elixir: "~> 1.14",
      compilers: [:telemetria | Mix.compilers()],
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {TicTacToeChecker.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:telemetria, "~> 0.12"},
      {:siblings, "~> 0.9"},
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false}
    ]
  end
end
