defmodule TicTacToeCheckerTest do
  use ExUnit.Case
  doctest TicTacToeChecker

  test "start/0" do
    pid = Process.whereis(TicTacToeChecker)

    assert %{id: 36, results: results} = GenServer.call(pid, :state)

    assert [%{cells: [{0, 1}, {1, 1}, {2, 1}], player: 1}] =
             Enum.find(results, fn x -> length(x) > 0 end)
  end
end
