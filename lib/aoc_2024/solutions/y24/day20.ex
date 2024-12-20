defmodule Aoc2024.Solutions.Y24.Day20 do
  alias AoC.Input

  def parse(input, _part) do
    Input.read!(input) |> String.split("\n", trim: true)
  end

  def part_one(problem) do
    matrix =
      problem
      |> build_matrix()

    {start, _} = Enum.find(matrix, fn {_, {_, status}} -> status == :start end)
    {finish, _} = Enum.find(matrix, fn {_, {_, status}} -> status == :finish end)

    graph = build_graph(matrix)

    shortcuts = find_shortcut(matrix)

    dbg(MapSet.size(shortcuts))

    pico =
      (Graph.dijkstra(graph, start, finish)
       |> Enum.count()) - 1

    shortcuts
    |> split_into_chunks()
    |> Task.async_stream(
      fn options ->
        Enum.map(options, fn {x, y} ->
          updated_graph =
            get_neighbours({x, y}, matrix)
            |> Enum.reduce(graph, fn {x_2, y_2}, graph ->
              Graph.add_edge(graph, Graph.Edge.new({x, y}, {x_2, y_2}))
            end)

          result =
            (Graph.dijkstra(updated_graph, start, finish)
             |> Enum.count()) - 1

          pico - result
        end)
      end,
      timeout: :infinity
    )
    |> merge_results_stream()
    |> Enum.filter(&(&1 >= 100))
    |> Enum.count()
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

  def find_shortcut(matrix) do
    Enum.reduce(Map.to_list(matrix), MapSet.new(), fn {_, {{x, y}, status}}, set ->
      if status == :wall do
        if check_if_single_wall(x, y, matrix) do
          MapSet.put(set, {x, y})
        else
          set
        end
      else
        set
      end
    end)
  end

  def check_if_single_wall(x, y, matrix) do
    up = fetch_neighbour({x - 1, y}, matrix)
    down = fetch_neighbour({x + 1, y}, matrix)
    left = fetch_neighbour({x, y - 1}, matrix)
    right = fetch_neighbour({x, y + 1}, matrix)

    options = [:open, :start, :finish]

    if (up in options and down in options) or (left in options and right in options) do
      true
    else
      false
    end
  end

  def fetch_neighbour({x, y}, matrix) do
    case Map.get(matrix, {x, y}) do
      {_, status} ->
        status

      _ ->
        :outside
    end
  end

  def build_graph(matrix) do
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

  def get_neighbours({x, y}, matrix) do
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
      Map.put(acc, {col_index, row_index}, {{col_index, row_index}, map_char(char)})
    end)
  end

  def map_char("S"), do: :start
  def map_char("E"), do: :finish
  def map_char("."), do: :open
  def map_char("#"), do: :wall

  @shortcut_range -20..20
  @shortcut_options for row <- @shortcut_range,
                        col <- @shortcut_range,
                        abs(row) + abs(col) <= 20,
                        do: {row, col}

  def part_two(problem) do
    matrix = build_matrix(problem)
    {start, finish} = find_special_points(matrix)

    path = Graph.dijkstra(build_graph(matrix), start, finish)
    position_map = build_position_map(path)

    calculate_valid_shortcuts(path, position_map)
  end

  defp find_special_points(matrix) do
    {start, _} = Enum.find(matrix, fn {_, {_, status}} -> status == :start end)
    {finish, _} = Enum.find(matrix, fn {_, {_, status}} -> status == :finish end)
    {start, finish}
  end

  defp build_position_map(path) do
    path
    |> Enum.with_index()
    |> Map.new()
  end

  defp calculate_valid_shortcuts(path, position_map) do
    path
    |> Enum.flat_map(&find_shortcuts(&1, position_map))
    |> Enum.filter(&(&1 >= 100))
    |> Enum.count()
  end

  defp find_shortcuts({row, col}, map) do
    from_index = Map.get(map, {row, col})

    @shortcut_options
    |> Enum.map(fn {o_row, o_col} ->
      evaluate_shortcut(map, {row, col}, {o_row, o_col}, from_index)
    end)
    |> Enum.reject(&(&1 == nil || &1 == 0))
  end

  defp evaluate_shortcut(map, {row, col}, {o_row, o_col}, from_index) do
    to_index = Map.get(map, {row + o_row, col + o_col})

    cond do
      to_index == nil -> nil
      to_index < from_index -> nil
      true -> to_index - from_index - abs(o_row) - abs(o_col)
    end
  end
end
