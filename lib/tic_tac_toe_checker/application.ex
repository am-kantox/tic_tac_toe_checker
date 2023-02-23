defmodule TicTacToeChecker.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @board [[0, 1, 0], [0, 1, 2], [0, 1, 2]]

  @impl Application
  @spec start(any, any) :: none()
  def start(_type, _args) do
    Logger.configure(level: :warn)

    children = [
      Siblings.child_spec(
        name: Siblings,
        die_with_children: &TicTacToeChecker.Application.report_result/0
      ),
      {TicTacToeChecker, board: @board}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: TicTacToeChecker.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl Application
  @spec prep_stop(any) :: :ok
  def prep_stop(state) do
    IO.puts(state)
    Process.sleep(1_000)
  end

  @spec report_result :: :ok
  def report_result do
    TicTacToeChecker
    |> GenServer.call(:state)
    |> case do
      %{
        board: _board,
        id: attempts,
        results: results
      } ->
        IO.puts("\n\nFinished. Examined #{attempts} paths.")

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

        IO.puts("Bye.\n")
    end
  end
end
