defmodule Aoc2024.Solutions.Y24.Day18 do
  alias AoC.Input

  alias Graph

  def parse(input, :part_one) do
    Input.read!(input)
    |> String.split("\n", trim: true)
    |> Enum.map(fn ip ->
      [x, y] = String.split(ip, ",")
      {String.to_integer(x), String.to_integer(y)}
    end)
  end

  def parse(input, :part_two) do
    corrupted_coords =
      Input.read!(input)
      |> String.split("\n", trim: true)

    Enum.map(corrupted_coords, fn ip ->
      [x, y] = String.split(ip, ",")
      {String.to_integer(x), String.to_integer(y)}
    end)
  end

  def part_one(problem) do
    matrix = build_matrix(71, 71)
    problem = Enum.slice(problem, 0..1023)

    steps =
      update_matrix(problem, matrix)
      |> build_graph()
      |> Graph.dijkstra({0, 0}, {70, 70})
      |> Enum.count()

    steps - 1
  end

  def build_graph(matrix) do
    Enum.reduce(Map.to_list(matrix), Graph.new(), fn {_, {x, y, status}}, graph ->
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
      {_, _, status} = Map.get(matrix, {x, y}, {-1, -1, :empty})
      status == :open
    end)
  end

  def update_matrix([], matrix) do
    matrix
  end

  def update_matrix([{x, y} | rest], matrix) do
    update_matrix(rest, Map.put(matrix, {x, y}, {x, y, :corrupted}))
  end

  def build_matrix(width, height) do
    Enum.with_index(0..(height - 1))
    |> Enum.reduce(%{}, fn row, acc ->
      build_matrix_row(row, acc, width)
    end)
  end

  def build_matrix_row({_row, row_index}, acc, width) do
    0..(width - 1)
    |> Enum.with_index()
    |> Enum.reduce(acc, fn {_char, col_index}, acc ->
      Map.put(acc, {col_index, row_index}, {col_index, row_index, :open})
    end)
  end

  def print_coordinates_grid(coordinates) do
    grid = for _ <- 0..6, do: for(_ <- 0..6, do: ".")

    updated_grid =
      Enum.reduce(coordinates, grid, fn {{x, y}, status}, acc ->
        List.update_at(acc, y, fn row ->
          List.update_at(row, x, fn _ -> map_char(status) end)
        end)
      end)

    file =
      Enum.reduce(updated_grid, "", fn row, acc ->
        acc <> Enum.join(row, "") <> "\n"
      end)

    File.write!("output.txt", file)
    coordinates
  end

  def map_char({_, _, :open}), do: "."
  def map_char({_, _, :corrupted}), do: "#"

  def part_two(corrupted_coords) do
    matrix = build_matrix(71, 71)
    graph = build_graph(matrix)

    find_first_bad_block_count(corrupted_coords, graph)
  end

  def find_first_bad_block_count([], _graph) do
    :unknown
  end

  def find_first_bad_block_count([new_corruption | rest], graph) do
    updated_graph = Graph.delete_vertex(graph, new_corruption)

    case Graph.dijkstra(updated_graph, {0, 0}, {70, 70}) do
      nil ->
        new_corruption

      _ ->
        find_first_bad_block_count(rest, updated_graph)
    end
  end
end
