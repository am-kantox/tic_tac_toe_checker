defmodule TicTacToeChecker do
  @moduledoc """
  Main _Checker_ process.
  Starts as `#{__MODULE__}.start_link(board: [[...]])` and returns the result of the board.
  """

  use GenServer

  @directions ~w|right down diag_r diag_l|a

  def start_link(opts) do
    GenServer.start_link(__MODULE__, %{board: opts[:board], id: 0, results: []}, name: __MODULE__)
  end

  @impl GenServer
  def init(%{board: board} = init_arg) do
    GenServer.cast(TicTacToeChecker, {:launch, {0, 0}})

    if valid?(board) do
      {:ok, %{init_arg | board: Enum.map(board, &Enum.map(&1, fn x -> {x, nil} end))}}
    else
      {:stop, :invalid_board}
    end
  end

  @impl GenServer
  def handle_cast({:launch, {x, y}}, state) do
    state.board
    |> get({x, y})
    |> case do
      {v, nil} ->
        board = set(state.board, {x, y}, state.id)

        id =
          Enum.reduce(@directions, state.id, fn direction, id ->
            id = id + 1

            :ok =
              Siblings.start_child(
                TicTacToeChecker.Crawler,
                id,
                %{
                  id: id,
                  x: x,
                  y: y,
                  direction: direction,
                  values: [{x, y, v}]
                },
                interval: 100_000
              )

            id
          end)

        {:noreply, %{state | board: board, id: id}}

      _ ->
        {:noreply, state}
    end
  end

  @impl GenServer
  def handle_cast({:done, %{id: id, values: values}}, state) do
    state = %{state | results: [{id, Enum.reverse(values)} | state.results]}
    IO.inspect(state, label: "Done")
    {:noreply, state}
  end

  @impl GenServer
  def handle_call({:move, %{x: x, y: y, direction: direction}}, _from, state) do
    {x, y} = redirect({x, y}, direction)
    {:reply, {get(state.board, {x, y}), {x, y}}, state}
  end

  defp valid?(board) do
    board |> List.flatten() |> Enum.frequencies() |> Map.take([1, 2]) |> Map.values() |> Enum.reduce(&Kernel.-/2) |> abs() |> Kernel.<=(1)
  end

  defp get(board, {x, y}) when x >= 0 and y >= 0 do
    get_in(board, [Access.at(x), Access.at(y)])
  end

  defp get(_board, _x_y), do: nil

  defp set(board, {x, y}, ids),
    do: update_in(board, [Access.at(x), Access.at(y)], fn {v, nil} -> {v, ids} end)

  defp redirect({x, y}, :right), do: {x + 1, y}
  defp redirect({x, y}, :down), do: {x, y + 1}
  defp redirect({x, y}, :diag_r), do: {x + 1, y + 1}
  defp redirect({x, y}, :diag_l), do: {x - 1, y + 1}
end
