defmodule Aoc2024.Solutions.Y24.Day15 do
  alias AoC.Input

  def parse(input, :part_one) do
    [grid, moves] =
      Input.read!(input)
      |> String.split("\n\n", trim: true)
      |> Enum.map(&String.split(&1, "\n", trim: true))

    grid = build_matrix(grid)
    moves = Enum.join(moves) |> String.graphemes() |> Enum.map(&map_direction/1)
    {grid, moves}
  end

  def parse(input, :part_two) do
    [grid, moves] =
      Input.read!(input)
      |> String.split("\n\n", trim: true)
      |> Enum.map(&String.split(&1, "\n", trim: true))

    grid =
      Enum.map(grid, fn grid_row ->
        String.replace(grid_row, "#", "##")
        |> String.replace("O", "[]")
        |> String.replace(".", "..")
        |> String.replace("@", "@.")
      end)
      |> build_matrix()

    moves = Enum.join(moves) |> String.graphemes() |> Enum.map(&map_direction/1)
    {grid, moves}
  end

  def part_one(problem) do
    {grid, moves} = problem

    start = Enum.find(grid, fn {_, v} -> v == :start end) |> elem(0)

    do_move(moves, start, grid)
    |> count_boxes()
  end

  def count_boxes(grid) do
    grid
    |> Enum.filter(fn {_, v} -> v in [:box, :box_l] end)
    |> Enum.reduce(0, fn {{x, y}, _}, acc ->
      acc + 100 * y + x
    end)
  end

  def do_move([], _, grid) do
    grid
  end

  def do_move([move | rest], {current_x, current_y}, grid) do
    case can_move?(grid, {current_x, current_y}, move, :start, []) do
      false ->
        do_move(rest, {current_x, current_y}, grid)

      moves ->
        updated_grid =
          moves
          |> Enum.reverse()
          |> Enum.reduce(grid, fn {prev_coord, next_coord, status}, grid ->
            Map.put(grid, prev_coord, :open)
            |> Map.put(next_coord, status)
          end)

        next_coord = get_next_coord({current_x, current_y}, move)

        final_grid =
          Map.put(updated_grid, next_coord, :start)
          |> Map.put({current_x, current_y}, :open)

        do_move(rest, next_coord, final_grid)
    end
  end

  def can_move?(grid, {current_x, current_y}, direction, moving, moves) do
    next_coord = get_next_coord({current_x, current_y}, direction)

    case Map.get(grid, next_coord) do
      :wall ->
        false

      :open ->
        moves ++ [{{current_x, current_y}, next_coord, moving}]

      :box ->
        next_move = Map.get(grid, next_coord)

        can_move?(
          grid,
          next_coord,
          direction,
          next_move,
          moves ++ [{{current_x, current_y}, next_coord, moving}]
        )
    end
  end

  def get_next_coord({current_x, current_y}, direction) do
    case direction do
      :up -> {current_x, current_y - 1}
      :down -> {current_x, current_y + 1}
      :left -> {current_x - 1, current_y}
      :right -> {current_x + 1, current_y}
    end
  end

  def print_coordinates_grid(coordinates) do
    grid = for _ <- 0..9, do: for(_ <- 0..19, do: ".")

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

    File.write!("output_.txt", file)
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
      Map.put(acc, {col_index, row_index}, map_char(char))
    end)
  end

  def map_char("#"), do: :wall
  def map_char("."), do: :open
  def map_char("@"), do: :start
  def map_char("O"), do: :box

  def map_char("["), do: :box_l
  def map_char("]"), do: :box_r

  def map_char(:wall), do: "#"
  def map_char(:open), do: "."
  def map_char(:start), do: "@"
  def map_char(:box), do: "0"
  def map_char(:touched), do: "X"
  def map_char(:box_l), do: "["
  def map_char(:box_r), do: "]"

  def map_direction("^"), do: :up
  def map_direction("v"), do: :down
  def map_direction("<"), do: :left
  def map_direction(">"), do: :right

  def part_two(problem) do
    {grid, moves} = problem

    {x, y} = Enum.find(grid, fn {_, v} -> v == :start end) |> elem(0)

    final_grid =
      do_move_2(moves, x, y, grid)

    print_coordinates_grid(final_grid)

    final_grid
    |> count_boxes()
  end

  def do_move_2([], _x, _y, grid), do: grid

  def do_move_2([move | rest], x, y, grid) do
    case do_row_update([{x, y}], move, grid) do
      :blocked ->
        do_move_2(rest, x, y, grid)

      coordinates ->
        updated_grid = update_grid_positions(coordinates, grid, move)
        {new_x, new_y} = move_coordinate({x, y}, move)

        final_grid =
          updated_grid
          |> Map.put({x, y}, :open)
          |> Map.put({new_x, new_y}, :start)

        do_move_2(rest, new_x, new_y, final_grid)
    end
  end

  def do_row_update([], _move, _grid), do: []

  def do_row_update(updates, move, grid) do
    next_row_updates =
      updates
      |> Enum.flat_map(fn coord ->
        get_affected_squares(coord, move, grid)
      end)
      |> Enum.uniq()
      |> Enum.reject(fn coord -> grid[coord] == :open end)

    case Enum.any?(next_row_updates, fn coord -> grid[coord] == :wall end) do
      true ->
        :blocked

      false ->
        # dbg("No Walls")
        # dbg(next_row_updates)

        case next_row_updates do
          [] ->
            updates

          _ ->
            next_moves = do_row_update(next_row_updates, move, grid)

            case next_moves do
              :blocked -> :blocked
              moves -> (updates ++ moves) |> Enum.uniq()
            end

            # updates ++ do_row_update(next_row_updates, move, grid)
        end
    end
  end

  defp get_affected_squares({x, y}, move, _grid) when move in [:left, :right] do
    case move do
      :left -> [{x - 1, y}]
      :right -> [{x + 1, y}]
    end
  end

  defp get_affected_squares({x, y}, move, grid) when move in [:up, :down] do
    y_offset = if move == :up, do: -1, else: 1
    moving_square = Map.get(grid, {x, y + y_offset})

    case moving_square do
      :box_l ->
        [{x, y + y_offset}, {x + 1, y + y_offset}]

      :box_r ->
        [{x, y}]
        [{x - 1, y + y_offset}, {x, y + y_offset}]

      _ ->
        [{x, y + y_offset}]
    end
  end

  defp update_grid_positions(coordinates, grid, move) do
    coordinates
    |> Enum.reverse()
    |> Enum.reduce(grid, fn coord, acc_grid ->
      value = grid[coord]
      new_coord = move_coordinate(coord, move)

      acc_grid
      |> Map.put(coord, :open)
      |> Map.put(new_coord, value)
    end)
  end

  defp move_coordinate({x, y}, move) do
    case move do
      :left -> {x - 1, y}
      :right -> {x + 1, y}
      :up -> {x, y - 1}
      :down -> {x, y + 1}
    end
  end
end
