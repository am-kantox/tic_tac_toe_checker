defmodule TicTacToeChecker.Crawler do
  @moduledoc """
  `Finitomata` implementation for TicTacToe.
  """

  @behaviour Siblings.Worker

  @win_size 3

  @impl Siblings.Worker
  def perform(_current, _id, _payload) do
    :noop
  end

  @fsm """
  idle --> |init!| ready
  ready --> |move!| ready
  ready --> |move!| done
  """

  use Finitomata, fsm: @fsm, auto_terminate: true, impl_for: [:on_transition]

  @impl Finitomata
  def on_transition(:idle, :init!, _, payload) do
    {:ok, :ready, payload}
  end

  @impl Finitomata
  def on_transition(:ready, :move!, _, payload) do
    TicTacToeChecker
    |> GenServer.call({:move, payload})
    |> case do
      {nil, _} ->
        if length(payload.values) >= @win_size,
          do: GenServer.cast(TicTacToeChecker, {:done, payload})

        {:ok, :done, payload}

      {{v, _}, {x, y}} ->
        GenServer.cast(TicTacToeChecker, {:launch, {x, y}})
        {:ok, :ready, %{payload | x: x, y: y, values: [{x, y, v} | payload.values]}}
    end
  end
end
