defmodule Aoc2024.Solutions.Y24.Day10 do
  alias AoC.Input

  def parse(input, _part) do
    Input.read!(input) |> String.split("\n", trim: true)
  end

  def part_one(problem) do
    matrix =
      problem
      |> pad_grid()
      |> build_matrix()

    Enum.filter(matrix, fn {_, {_, _, v}} -> v == 0 end)
    |> Enum.map(fn {_, {x, y, v}} -> {x, y, v} end)
    |> find_trails(matrix)
  end

  def find_trails(ths, matrix) do
    Enum.map(ths, fn th ->
      find_trail(th, matrix, MapSet.new()) |> Enum.count()
    end)
    |> Enum.sum()
  end

  def find_trail({_x, _y, val} = head, _matrix, _acc) when val == 9, do: MapSet.new([head])

  def find_trail(th, matrix, acc) do
    routes = fetch_routes(th, matrix)

    case routes do
      [] ->
        acc

      _ ->
        MapSet.union(
          acc,
          MapSet.new(
            Enum.flat_map(routes, fn th ->
              find_trail(th, matrix, acc)
            end)
          )
        )
    end
  end

  def fetch_routes({x, y, val}, matrix) do
    [
      fetch_route(x - 1, y, matrix),
      fetch_route(x, y - 1, matrix),
      fetch_route(x + 1, y, matrix),
      fetch_route(x, y + 1, matrix)
    ]
    |> Enum.filter(fn {_x, _y, option} ->
      case val do
        "." ->
          false

        _ ->
          option == val + 1
      end
    end)
  end

  def fetch_route(x, y, matrix) do
    Map.get(matrix, {x, y}, {0, 0, nil})
  end

  def pad_grid(grid) do
    row_size = List.first(grid) |> String.length()

    pad_row = List.duplicate(".", row_size) |> List.to_string()

    [pad_row] ++
      Enum.map(grid, fn row ->
        "." <> row <> "."
      end) ++ [pad_row]
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
      case Integer.parse(char) do
        {i, _} ->
          Map.put(acc, {col_index, row_index}, {col_index, row_index, i})

        :error ->
          Map.put(acc, {col_index, row_index}, {col_index, row_index, char})
      end
    end)
  end

  def part_two(problem) do
    matrix =
      problem
      |> pad_grid()
      |> build_matrix()

    Enum.filter(matrix, fn {_, {_, _, v}} -> v == 0 end)
    |> Enum.map(fn {_, {x, y, v}} -> {x, y, v} end)
    |> find_trails_part_2(matrix)
  end

  def find_trails_part_2(ths, matrix) do
    Enum.map(ths, fn th ->
      find_trail_2(th, matrix, []) |> Enum.count()
    end)
    |> Enum.sum()
  end

  def find_trail_2({_x, _y, val} = head, _matrix, _acc) when val == 9, do: [head]

  def find_trail_2(th, matrix, acc) do
    routes = fetch_routes(th, matrix)

    case routes do
      [] ->
        acc

      _ ->
        acc ++
          Enum.flat_map(routes, fn th ->
            find_trail_2(th, matrix, acc)
          end)
    end
  end
end
