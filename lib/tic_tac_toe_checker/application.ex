defmodule TicTacToeChecker.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @board [[0, 1, 2], [0, 1, 1], [0, 1, 1]]

  @impl true
  def start(_type, _args) do
    children = [
      {Siblings, []},
      {TicTacToeChecker, board: @board}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: TicTacToeChecker.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
