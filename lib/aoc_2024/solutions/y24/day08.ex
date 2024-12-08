defmodule Aoc2024.Solutions.Y24.Day08 do
  alias AoC.Input

  def parse(input, _part) do
    Input.read!(input) |> String.split("\n", trim: true)
  end

  def part_one(problem) do
    do_work(problem, :part_one)
  end

  def part_two(problem) do
    do_work(problem, :part_two)
  end

  def do_work(problem, part) do
    grid_width = String.length(List.first(problem))
    grid_height = length(problem)

    build_antennas(problem)
    |> build_reflections(grid_width, grid_height, part)
    |> Enum.filter(fn {x, y} ->
      x >= 0 && x <= grid_width - 1 && (y >= 0 && y <= grid_height - 1)
    end)
    |> Enum.count()
  end

  def build_antennas(problem) do
    Enum.with_index(problem)
    |> Enum.flat_map(fn {row, row_index} ->
      Enum.with_index(String.graphemes(row))
      |> Enum.filter(fn {char, _} -> char != "." end)
      |> Enum.map(fn {char, col_index} -> {char, col_index, row_index} end)
    end)
    |> Enum.group_by(fn {antenna, _col_index, _row_index} -> antenna end)
  end

  def build_reflections(antennas, grid_width, grid_height, part) do
    antennas
    |> Map.to_list()
    |> Enum.map(&build_reflection_pairs/1)
    |> make_reflections(grid_width, grid_height, part)
  end

  def build_reflection_pairs({antenna, locations}) do
    options =
      Enum.reduce(locations, MapSet.new(), fn {_, col_index_1, row_index_1}, acc ->
        Enum.reduce(locations, acc, fn {_, col_index_2, row_index_2}, acc ->
          if col_index_1 == col_index_2 && row_index_1 == row_index_2 do
            acc
          else
            MapSet.put(
              acc,
              [{col_index_1, row_index_1}, {col_index_2, row_index_2}]
              |> Enum.sort()
              |> List.to_tuple()
            )
          end
        end)
      end)

    {antenna, options}
  end

  def make_reflections(pairs, grid_width, grid_height, part) do
    Enum.reduce(pairs, MapSet.new(), fn {_antenna_type, coord_pairs}, acc ->
      Enum.reduce(coord_pairs, acc, fn pair, acc ->
        MapSet.union(acc, make_reflection(pair, grid_width, grid_height, part))
      end)
    end)
  end

  def make_reflection({{x_1, y_1}, {x_2, y_2}}, _grid_width, _grid_height, :part_one) do
    x_spacing = x_2 - x_1
    y_spacing = get_y(y_1, y_2)
    reflect_1 = {x_1 - x_spacing, y_1 - y_spacing}
    reflect_2 = {x_2 + x_spacing, y_2 + y_spacing}
    MapSet.new([reflect_1, reflect_2])
  end

  def make_reflection(
        {{x_1, y_1} = reflect_1, {x_2, y_2} = reflect_2},
        grid_width,
        grid_height,
        :part_two
      ) do
    x_spacing = x_2 - x_1
    y_spacing = get_y(y_1, y_2)

    MapSet.new([reflect_1, reflect_2])
    |> iterate_reflection({x_1, y_1}, -x_spacing, -y_spacing, grid_width, grid_height)
    |> iterate_reflection({x_2, y_2}, x_spacing, y_spacing, grid_width, grid_height)
  end

  def iterate_reflection(
        acc,
        {current_x, current_y},
        x_spacing,
        y_spacing,
        grid_width,
        grid_height
      )
      when current_x + x_spacing >= 0 and current_y + y_spacing >= 0 and
             current_x + x_spacing <= grid_width - 1 and current_y + y_spacing <= grid_height - 1 do
    new_reflection = {current_x + x_spacing, current_y + y_spacing}

    iterate_reflection(
      MapSet.put(acc, new_reflection),
      new_reflection,
      x_spacing,
      y_spacing,
      grid_width,
      grid_height
    )
  end

  def iterate_reflection(
        acc,
        _,
        _x_spacing,
        _y_spacing,
        _grid_width,
        _grid_height
      ) do
    acc
  end

  def get_y(y_1, y_2) when y_1 <= y_2 do
    y_2 - y_1
  end

  def get_y(y_1, y_2) do
    y_2 - y_1
  end
end
