defmodule Aoc2024.Solutions.Y24.Day20 do
  alias AoC.Input

  def parse(input, _part) do
    Input.read!(input) |> String.split("\n", trim: true)
  end

  @delta_limits_part_one -2..2
  @possible_jumps_part_one for x <- @delta_limits_part_one,
                               y <- @delta_limits_part_one,
                               manhattan_distance = abs(x) + abs(y),
                               manhattan_distance <= 2,
                               do: {x, y}

  def part_one(input) do
    grid = build_matrix(input)
    {origin, target} = locate_endpoints(grid)

    route = Graph.dijkstra(build_graph(grid), origin, target)
    locations = index_positions(route)

    find_valid_jumps(route, locations, @possible_jumps_part_one)
  end

  defp split_into_chunks(options) do
    workers = :erlang.system_info(:schedulers_online)
    options_count = Enum.count(options)
    options_per_chunk = :erlang.ceil(options_count / workers)

    Enum.chunk_every(options, options_per_chunk)
  end

  defp merge_results_stream(results_stream) do
    Enum.reduce(results_stream, [], fn {:ok, worker_result}, acc ->
      acc ++ worker_result
    end)
  end

  defp build_graph(matrix) do
    Enum.reduce(Map.to_list(matrix), Graph.new(type: :undirected), fn {_, {{x, y}, status}},
                                                                      graph ->
      if status == :open do
        get_neighbours({x, y}, matrix)
        |> Enum.reduce(graph, fn {x_2, y_2}, graph ->
          Graph.add_edge(graph, Graph.Edge.new({x, y}, {x_2, y_2}))
        end)
      else
        graph
      end
    end)
  end

  defp get_neighbours({x, y}, matrix) do
    [
      {x - 1, y},
      {x + 1, y},
      {x, y - 1},
      {x, y + 1}
    ]
    |> Enum.filter(fn {x, y} ->
      {_, status} = Map.get(matrix, {x, y}, {-1, -1, :empty})
      status in [:open, :start, :finish]
    end)
  end

  defp build_matrix(grid) do
    Enum.with_index(grid)
    |> Enum.reduce(%{}, fn row, acc ->
      build_matrix_row(row, acc)
    end)
  end

  defp build_matrix_row({row, row_index}, acc) do
    row
    |> String.graphemes()
    |> Enum.with_index()
    |> Enum.reduce(acc, fn {char, col_index}, acc ->
      Map.put(acc, {col_index, row_index}, {{col_index, row_index}, map_char(char)})
    end)
  end

  defp map_char("S"), do: :start
  defp map_char("E"), do: :finish
  defp map_char("."), do: :open
  defp map_char("#"), do: :wall

  @delta_limits_part_two -20..20
  @possible_jumps_part_two for x <- @delta_limits_part_two,
                               y <- @delta_limits_part_two,
                               manhattan_distance = abs(x) + abs(y),
                               manhattan_distance <= 20,
                               do: {x, y}

  def part_two(input) do
    grid = build_matrix(input)
    {origin, target} = locate_endpoints(grid)

    route = Graph.dijkstra(build_graph(grid), origin, target)
    locations = index_positions(route)

    find_valid_jumps(route, locations, @possible_jumps_part_two)
  end

  defp locate_endpoints(grid) do
    [{entry, _}] = Enum.filter(grid, fn {_, {_, type}} -> type == :start end)
    [{exit, _}] = Enum.filter(grid, fn {_, {_, type}} -> type == :finish end)
    {entry, exit}
  end

  defp index_positions(route) do
    route
    |> Stream.with_index()
    |> Enum.into(%{})
  end

  defp find_valid_jumps(route, locations, possible_jumps) do
    route
    |> split_into_chunks()
    |> Task.async_stream(fn parts ->
      Enum.flat_map(parts, &scan_jumps(&1, locations, possible_jumps))
    end)
    |> merge_results_stream()
    |> Stream.filter(&(&1 >= 100))
    |> Enum.count()
  end

  defp scan_jumps({x, y}, locations, possible_jumps) do
    current = Map.fetch!(locations, {x, y})

    possible_jumps
    |> Stream.map(&check_jump(locations, {x, y}, &1, current))
    |> Stream.reject(&is_nil/1)
  end

  defp check_jump(locations, {x, y}, {dx, dy}, start_idx) do
    case Map.get(locations, {x + dx, y + dy}) do
      nil -> nil
      end_idx when end_idx <= start_idx -> nil
      end_idx -> end_idx - start_idx - abs(dx) - abs(dy)
    end
  end
end
