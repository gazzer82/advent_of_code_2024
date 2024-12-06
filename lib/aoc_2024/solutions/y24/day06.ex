defmodule Aoc2024.Solutions.Y24.Day06 do
  alias AoC.Input

  def parse(input, _part) do
    Input.read!(input) |> String.split("\n", trim: true)
  end

  def part_one(problem) do
    matrix = problem |> build_matrix()

    find_start_position(matrix)
    |> move(matrix, :up)
    |> Map.to_list()
    |> Enum.filter(fn {_, v} -> v in ["X", "^"] end)
    |> Enum.count()
  end

  def move(current_position, matrix, direction) do
    next_coord = next_coord(current_position, direction)

    case Map.get(matrix, next_coord) do
      nil ->
        matrix

      square ->
        {next_position, matrix, direction} =
          check_next_position(square, direction, matrix, next_coord, current_position)

        move(next_position, matrix, direction)
    end
  end

  def check_next_position(square, direction, matrix, next_position, _current_position)
      when square in [".", "X", "^"] do
    {next_position, Map.put(matrix, next_position, "X"), direction}
  end

  def check_next_position(_square, direction, matrix, _next_position, current_position) do
    {current_position, matrix, rotate_direction(direction)}
  end

  def find_start_position(matrix) do
    matrix
    |> Enum.to_list()
    |> Enum.find(fn {_, v} -> v == "^" end)
    |> elem(0)
  end

  def build_matrix(grid) do
    Enum.with_index(grid)
    |> Enum.reduce(%{}, fn row, acc ->
      build_matrix_row(row, acc)
    end)
  end

  def build_matrix_row({row, row_index}, acc) do
    row
    |> String.graphemes()
    |> Enum.with_index()
    |> Enum.reduce(acc, fn {char, col_index}, acc ->
      Map.put(acc, {col_index, row_index}, char)
    end)
  end

  def next_coord({current_x, current_y}, direction) do
    case direction do
      :up -> {current_x, current_y - 1}
      :down -> {current_x, current_y + 1}
      :left -> {current_x - 1, current_y}
      :right -> {current_x + 1, current_y}
    end
  end

  def rotate_direction(:up), do: :right

  def rotate_direction(:right), do: :down

  def rotate_direction(:down), do: :left

  def rotate_direction(:left), do: :up

  def set_square_visited(matrix, {x, y}) do
    Map.put(matrix, {x, y}, "X")
  end

  def part_two(problem) do
    matrix = problem |> build_matrix()
    start = find_start_position(matrix)

    options =
      find_start_position(matrix)
      |> move(matrix, :up)
      |> Map.to_list()
      |> Enum.filter(fn {_, v} -> v == "X" end)

    Enum.map(options, fn {{x, y}, _} ->
      Task.async(fn ->
        test_matrix = Map.put(matrix, {x, y}, "#")
        move_2(start, test_matrix, :up, MapSet.new())
      end)
    end)
    |> Task.await_many(:infinity)
    |> Enum.filter(& &1)
    |> Enum.count()
  end

  def move_2(current_position, matrix, direction, previous) do
    if check_been_here_before(current_position, direction, previous) do
      true
    else
      next_coord = next_coord(current_position, direction)

      case Map.get(matrix, next_coord) do
        nil ->
          false

        square ->
          {next_position, matrix, direction, backtrack} =
            check_next_position_2(square, direction, matrix, next_coord, current_position)

          if backtrack do
            move_2(current_position, matrix, direction, previous)
          else
            move_2(
              next_position,
              matrix,
              direction,
              MapSet.put(previous, {current_position, direction})
            )
          end
      end
    end
  end

  def check_been_here_before(current_position, direction, previous) do
    MapSet.member?(previous, {current_position, direction})
  end

  def check_next_position_2(square, direction, matrix, next_position, _current_position)
      when square in [".", "X", "^"] do
    {next_position, Map.put(matrix, next_position, "X"), direction, false}
  end

  def check_next_position_2(_square, direction, matrix, _next_position, current_position) do
    {current_position, matrix, rotate_direction(direction), true}
  end
end