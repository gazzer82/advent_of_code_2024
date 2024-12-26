defmodule Aoc2024.Solutions.Y24.Day23 do
  alias AoC.Input

  def parse(input, _part) do
    problem =
      Input.read!(input)
      |> String.split("\n", trim: true)
      |> Enum.map(&(String.split(&1, "-") |> Enum.map(fn string -> String.to_atom(string) end)))
      |> Enum.map(&List.to_tuple(&1))

    graph =
      problem
      |> Enum.reduce(%{}, fn {left, right}, map ->
        Map.put(map, {left, right}, :null)
        |> Map.put({right, left}, :null)
        |> Map.update(left, MapSet.new([right]), fn list -> MapSet.put(list, right) end)
        |> Map.update(right, MapSet.new([left]), fn list -> MapSet.put(list, left) end)
      end)

    relationship =
      problem
      |> Enum.reduce(%{}, fn {left, right}, map ->
        Map.update(map, left, MapSet.new([right]), fn list -> MapSet.put(list, right) end)
        |> Map.update(right, MapSet.new([left]), fn list -> MapSet.put(list, left) end)
      end)

    {graph, relationship}
  end

  def part_one({graph, relationship}) do
    relationship
    |> Map.to_list()
    |> Enum.filter(fn {key, _set} -> String.starts_with?(Atom.to_string(key), "t") end)
    |> Enum.reduce(MapSet.new(), fn {key, set}, map ->
      set = MapSet.to_list(set)

      triangles =
        for x <- set,
            y <- set,
            x != y,
            do: [x, y]

      triangles =
        triangles
        |> Enum.filter(fn [x, y] ->
          Map.has_key?(graph, {x, y})
        end)
        |> Enum.map(&(([key] ++ &1) |> Enum.sort()))
        |> MapSet.new()

      MapSet.union(map, triangles)
    end)
    |> MapSet.size()
  end

  def part_two({graph, relationship}) do
    relationship
    |> Map.to_list()
    |> Enum.filter(fn {key, _set} -> String.starts_with?(Atom.to_string(key), "t") end)
    |> Enum.flat_map(fn {key, set} ->
      set = MapSet.to_list(set)
      bron_kerbosch(graph, [key], set)
    end)
    # |> Enum.filter(&(length(&1) == 3))
    |> Enum.map(&Enum.sort(&1))
    |> Enum.uniq()
    |> Enum.sort_by(&length(&1), :desc)
    |> hd()
    |> Enum.join(",")
  end

  def bron_kerbosch(_graph, [], []) do
    []
  end

  def bron_kerbosch(_graph, clique, []) do
    [clique]
  end

  def bron_kerbosch(graph, clique, [option | rest]) do
    case connected_to_all(graph, clique, option) do
      true ->
        bron_kerbosch(graph, [option | clique], rest) ++ bron_kerbosch(graph, clique, rest)

      false ->
        bron_kerbosch(graph, clique, rest)
    end
  end

  def connected_to_all(graph, clique, option) do
    Enum.reduce_while(clique, true, fn opt, valid ->
      case Map.has_key?(graph, {option, opt}) do
        true -> {:cont, valid}
        false -> {:halt, false}
      end
    end)
  end
end
