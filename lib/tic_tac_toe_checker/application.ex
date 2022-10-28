defmodule TicTacToeChecker.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @board [[0, 1, 0], [0, 1, 2], [0, 1, 2]]

  @impl true
  def start(_type, _args) do
    Logger.configure(level: :warn)

    children = [
      {Siblings, callbacks: [on_enter: &TicTacToeChecker.Application.maybe_terminate/1]},
      {TicTacToeChecker, board: @board}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: TicTacToeChecker.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def maybe_terminate(_) do
    Task.start(fn ->
      if Siblings.state().payload[:workers] == %{} do
        TicTacToeChecker
        |> GenServer.call(:state)
        |> case do
          %{reported: true} ->
            :ok

          %{
            board: _board,
            id: attempts,
            results: results
          } ->
            IO.puts("Finished. Examined #{attempts} paths.")

            results
            |> List.flatten()
            |> case do
              [] ->
                "No winner."

              [%{cells: cells, player: player}] ->
                "Player ##{player} wins at " <> inspect(cells) <> "."

              multi ->
                "Multiple winners :( " <> inspect(multi) <> "."
            end
            |> IO.puts()

            IO.puts("Bye.")

            Application.stop(:tic_tac_toe_checker)
        end
      end
    end)
  end
end
