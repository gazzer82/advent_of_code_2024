defmodule Aoc2024.Solutions.Y24.Day04 do
  alias AoC.Input

  def parse(input, _part) do
    Input.read!(input) |> String.split("\n", trim: true) |> pad_grid()
  end

  def part_one(problem) do
    matrix = problem |> build_matrix()
    matrix |> Enum.to_list() |> Enum.filter(fn {_, v} -> v == "X" end) |> find_xmas(matrix)
  end

  def find_xmas(xs, matrix) do
    Enum.reduce(xs, [], fn {x_coords, _}, acc ->
      acc ++
        [
          find_next(x_coords, :up, ["M", "A", "S"], matrix),
          find_next(x_coords, :down, ["M", "A", "S"], matrix),
          find_next(x_coords, :left, ["M", "A", "S"], matrix),
          find_next(x_coords, :right, ["M", "A", "S"], matrix),
          find_next(x_coords, :diag_up_right, ["M", "A", "S"], matrix),
          find_next(x_coords, :diag_down_right, ["M", "A", "S"], matrix),
          find_next(x_coords, :diag_up_left, ["M", "A", "S"], matrix),
          find_next(x_coords, :diag_down_left, ["M", "A", "S"], matrix)
        ]
    end)
    |> Enum.filter(&(&1 == 1))
    |> Enum.count()
  end

  def find_next(_, _, [], _), do: 1

  def find_next({current_x, current_y}, direction, [next_letter | tail], matrix) do
    next_coords = get_next_coord({current_x, current_y}, direction)
    next_match = Map.get(matrix, next_coords)

    if next_letter == next_match do
      find_next(next_coords, direction, tail, matrix)
    else
      0
    end
  end

  def pad_grid(problem) do
    [first | _] = problem
    width = String.length(first)
    pad_row = 1..width |> Enum.map(fn _ -> "." end) |> Enum.join()
    [pad_row] ++ Enum.map(problem, &".#{&1}.") ++ [pad_row]
  end

  #

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

  def get_next_coord({current_x, current_y}, direction) do
    case direction do
      :up -> {current_x, current_y - 1}
      :down -> {current_x, current_y + 1}
      :left -> {current_x - 1, current_y}
      :right -> {current_x + 1, current_y}
      :diag_up_right -> {current_x + 1, current_y - 1}
      :diag_down_right -> {current_x + 1, current_y + 1}
      :diag_up_left -> {current_x - 1, current_y - 1}
      :diag_down_left -> {current_x - 1, current_y + 1}
    end
  end

  def part_two(problem) do
    matrix = problem |> build_matrix()
    matrix |> Enum.to_list() |> Enum.filter(fn {_, v} -> v == "A" end) |> find_x_mases(matrix)
  end

  def find_x_mases(as, matrix) do
    Enum.reduce(as, [], fn a, acc ->
      acc ++ [find_x_mas(a, matrix)]
    end)
    |> Enum.filter(& &1)
    |> Enum.count()
  end

  def find_x_mas({{coord_x, coord_y}, _}, matrix) do
    cross_1 =
      [
        Map.get(matrix, {coord_x - 1, coord_y - 1}),
        Map.get(matrix, {coord_x, coord_y}),
        Map.get(matrix, {coord_x + 1, coord_y + 1})
      ]
      |> List.to_string()

    cross_2 =
      [
        Map.get(matrix, {coord_x + 1, coord_y - 1}),
        Map.get(matrix, {coord_x, coord_y}),
        Map.get(matrix, {coord_x - 1, coord_y + 1})
      ]
      |> List.to_string()

    cross_1 in ["MAS", "SAM"] && cross_2 in ["MAS", "SAM"]
  end
end
