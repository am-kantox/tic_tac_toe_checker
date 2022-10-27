defmodule TicTacToeCheckerTest do
  use ExUnit.Case
  doctest TicTacToeChecker

  test "greets the world" do
    assert TicTacToeChecker.hello() == :world
  end
end
