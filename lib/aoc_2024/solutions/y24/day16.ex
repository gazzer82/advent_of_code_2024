defmodule Aoc2024.Solutions.Y24.Day16 do
  alias AoC.Input

  def parse(input, _part) do
    Input.read!(input) |> String.split("\n", trim: true)
  end

  def part_one(problem) do
    matrix = problem |> build_matrix()
    {start_x, start_y} = find_start_position(matrix)
    fin = find_finish_position(matrix)
    start = {0, {start_x, start_y, :start, :east, [{start_x, start_y}]}}

    find_routes(matrix, Heap.new() |> Heap.push(start), fin, MapSet.new())
  end

  def find_routes(matrix, options, finish, visited) do
    case Heap.empty?(options) do
      true ->
        :no_route_found

      _ ->
        {{cost, {x, y, _, direction, path}}, set2} = Heap.split(options)
        updated_visited = MapSet.put(visited, {{x, y}, direction})

        cond do
          {x, y} == finish ->
            cost

          MapSet.member?(visited, {{x, y}, direction}) ->
            find_routes(matrix, set2, finish, visited)

          true ->
            new_options = find_options(matrix, {x, y}, direction, visited, cost, path)
            options = Enum.reduce(new_options, set2, &Heap.push(&2, &1))
            find_routes(matrix, options, finish, updated_visited)
        end
    end
  end

  def find_options(matrix, {x, y}, orientation, visited, cost, path) do
    north =
      Map.get(matrix, {x, y - 1}) |> Tuple.append(:north) |> Tuple.append(path ++ [{x, y - 1}])

    south =
      Map.get(matrix, {x, y + 1}) |> Tuple.append(:south) |> Tuple.append(path ++ [{x, y + 1}])

    east =
      Map.get(matrix, {x + 1, y}) |> Tuple.append(:east) |> Tuple.append(path ++ [{x + 1, y}])

    west =
      Map.get(matrix, {x - 1, y}) |> Tuple.append(:west) |> Tuple.append(path ++ [{x - 1, y}])

    case orientation do
      :north ->
        [{1 + cost, north}, {1001 + cost, east}, {1001 + cost, west}]

      :south ->
        [{1 + cost, south}, {1001 + cost, east}, {1001 + cost, west}]

      :east ->
        [{1001 + cost, north}, {1001 + cost, south}, {1 + cost, east}]

      :west ->
        [{1001 + cost, north}, {1001 + cost, south}, {1 + cost, west}]
    end
    |> Enum.filter(fn {_, {_, _, square, _, _}} -> square != :wall end)
    |> Enum.filter(fn {_, {x, y, _, direction, _}} ->
      !MapSet.member?(visited, {{x, y}, direction})
    end)
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
      Map.put(acc, {col_index, row_index}, {col_index, row_index, map_square(char)})
    end)
  end

  def map_square(square) do
    case square do
      "S" -> :start
      "E" -> :end
      "#" -> :wall
      "." -> :open
    end
  end

  def find_start_position(matrix) do
    matrix
    |> Enum.to_list()
    |> Enum.find(fn {_, {_, _, v}} -> v == :start end)
    |> elem(0)
  end

  def find_finish_position(matrix) do
    matrix
    |> Enum.to_list()
    |> Enum.find(fn {_, {_, _, v}} -> v == :end end)
    |> elem(0)
  end

  def part_two(problem) do
    matrix = problem |> build_matrix()
    {start_x, start_y} = find_start_position(matrix)
    fin = find_finish_position(matrix)
    start = {0, {start_x, start_y, :start, :east, [{start_x, start_y}]}}

    find_routes_part_2(matrix, Heap.new() |> Heap.push(start), fin, MapSet.new(), :infinity, [])
    # |> length()

    |> Enum.reduce(MapSet.new(), fn path, acc ->
      Enum.reduce(
        path,
        acc,
        fn step, acc ->
          MapSet.put(acc, step)
        end
      )
    end)
    |> MapSet.size()
  end

  def find_routes_part_2(matrix, options, finish, cost_map, shortest_cost, shortest_paths) do
    case Heap.empty?(options) do
      true ->
        shortest_paths

      _ ->
        {{cost, {x, y, _, direction, path}}, set2} = Heap.split(options)
        current_cost = Map.get(cost_map, {{x, y}, direction}, :infinity)

        cond do
          {x, y} == finish ->
            cond do
              shortest_cost == :infinity ->
                find_routes_part_2(matrix, set2, finish, cost_map, cost, [path])

              cost == shortest_cost ->
                find_routes_part_2(matrix, set2, finish, cost_map, shortest_cost, [
                  path | shortest_paths
                ])

              true ->
                find_routes_part_2(matrix, set2, finish, cost_map, shortest_cost, shortest_paths)
            end

          cost <= current_cost ->
            new_cost_map = Map.put(cost_map, {{x, y}, direction}, cost)
            new_options = find_options_part_2(matrix, {x, y}, direction, cost, path)
            options = Enum.reduce(new_options, set2, &Heap.push(&2, &1))

            find_routes_part_2(
              matrix,
              options,
              finish,
              new_cost_map,
              shortest_cost,
              shortest_paths
            )

          true ->
            find_routes_part_2(matrix, set2, finish, cost_map, shortest_cost, shortest_paths)
        end
    end
  end

  def find_options_part_2(matrix, {x, y}, orientation, cost, path) do
    north =
      Map.get(matrix, {x, y - 1}) |> Tuple.append(:north) |> Tuple.append(path ++ [{x, y - 1}])

    south =
      Map.get(matrix, {x, y + 1}) |> Tuple.append(:south) |> Tuple.append(path ++ [{x, y + 1}])

    east =
      Map.get(matrix, {x + 1, y}) |> Tuple.append(:east) |> Tuple.append(path ++ [{x + 1, y}])

    west =
      Map.get(matrix, {x - 1, y}) |> Tuple.append(:west) |> Tuple.append(path ++ [{x - 1, y}])

    case orientation do
      :north ->
        [{1 + cost, north}, {1001 + cost, east}, {1001 + cost, west}]

      :south ->
        [{1 + cost, south}, {1001 + cost, east}, {1001 + cost, west}]

      :east ->
        [{1001 + cost, north}, {1001 + cost, south}, {1 + cost, east}]

      :west ->
        [{1001 + cost, north}, {1001 + cost, south}, {1 + cost, west}]
    end
    |> Enum.filter(fn {_, {_, _, square, _, _}} -> square != :wall end)
  end
end
