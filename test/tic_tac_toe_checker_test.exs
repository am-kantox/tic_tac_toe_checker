defmodule TicTacToeCheckerTest do
  use ExUnit.Case
  doctest TicTacToeChecker

  test "start/0" do
    pid = Process.whereis(TicTacToeChecker)

    assert %{id: 36, results: results} = GenServer.call(pid, :state)

    assert [%{cells: [{0, 1}, {1, 1}, {2, 1}], player: 1}] =
             Enum.find(results, fn x -> length(x) > 0 end)
  end

  test "player 1 should win" do
    board = [[0, 1, 2], [0, 1, 2], [0, 1, 0]]
    TicTacToeChecker.start_link(board: board)
    Process.sleep(1_000)
    %{results: results} = GenServer.call(TicTacToeChecker, :state)

    assert [%{cells: _, player: 1}] = List.flatten(results)
  end

  test "player 2 should win" do
    board = [[0, 2, 1], [0, 2, 1], [1, 2, 0]]
    TicTacToeChecker.start_link(board: board)
    Process.sleep(1_000)
    %{results: results} = GenServer.call(TicTacToeChecker, :state)

    assert [%{cells: _, player: 2}] = List.flatten(results)
  end
end
