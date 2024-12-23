defmodule Aoc2024.Solutions.Y24.Day21 do
  alias AoC.Input

  def parse(input, _part) do
    Input.read!(input)
    |> String.split("\n", trim: true)
    |> Enum.map(fn code ->
      String.graphemes(code)
    end)
  end

  @num_loc_map %{
    "7" => {0, 0},
    "8" => {1, 0},
    "9" => {2, 0},
    "4" => {0, 1},
    "5" => {1, 1},
    "6" => {2, 1},
    "1" => {0, 2},
    "2" => {1, 2},
    "3" => {2, 2},
    "0" => {1, 3},
    "A" => {2, 3}
  }

  @dir_loc_map %{
    "^" => {1, 0},
    "A" => {2, 0},
    "<" => {0, 1},
    "V" => {1, 1},
    ">" => {2, 1}
  }

  def part_one(problem) do
    :ets.new(:steps_cache, [:named_table, :public, :set, :protected])

    target_digits =
      Enum.map(problem, fn digits ->
        Enum.filter(digits, &(&1 not in ["A"]))
        |> Enum.join()
        |> String.to_integer()
      end)

    result =
      Enum.map(problem, &calculate_number_steps(&1, 3, 0))
      |> Enum.zip(target_digits)
      |> Enum.map(fn {steps, target} -> steps * target end)
      |> Enum.sum()

    :ets.delete(:steps_cache)
    result
  end

  # +---+---+---+
  # | 7 | 8 | 9 |
  # +---+---+---+
  # | 4 | 5 | 6 |
  # +---+---+---+
  # | 1 | 2 | 3 |
  # +---+---+---+
  #     | 0 | A |
  #     +---+---+

  #     +---+---+
  #     | ^ | A |
  # +---+---+---+
  # | < | v | > |
  # +---+---+---+

  def calculate_number_steps(numbers, target_depth, depth) when target_depth == depth do
    Enum.count(numbers)
  end

  def calculate_number_steps(numbers, target_depth, depth) do
    case :ets.lookup(:steps_cache, {numbers, depth}) do
      [{_, result}] ->
        result

      [] ->
        start_loc = get_start_location(depth)
        faul_loc = get_fault_location(depth)

        {steps, _current_loc} =
          numbers
          |> Enum.reduce({0, start_loc}, fn target, {acc, current_loc} ->
            target = get_target(target, depth)

            buttons =
              calculate_steps(current_loc, target, faul_loc)
              |> Enum.map(fn seq ->
                calculate_number_steps(seq, target_depth, depth + 1)
              end)

            result = acc + Enum.min(buttons)

            :ets.insert(:steps_cache, {{numbers, depth}, result})

            {result, target}
          end)

        steps
    end
  end

  def calculate_steps({x, y}, {target_x, target_y}, {avoid_x, avoid_y}) do
    x_diff = target_x - x
    y_diff = target_y - y

    x_moves =
      if x > target_x do
        List.duplicate("<", abs(x_diff))
      else
        List.duplicate(">", abs(x_diff))
      end

    y_moves =
      if y > target_y do
        List.duplicate("^", abs(y_diff))
      else
        List.duplicate("V", abs(y_diff))
      end

    moves =
      cond do
        y == avoid_y and target_x == avoid_x ->
          [y_moves ++ x_moves ++ ["A"]]

        x == avoid_x and target_y == avoid_y ->
          [x_moves ++ y_moves ++ ["A"]]

        true ->
          [x_moves ++ y_moves ++ ["A"], y_moves ++ x_moves ++ ["A"]]
      end

    moves
  end

  def get_start_location(depth) when depth == 0, do: {2, 3}

  def get_start_location(_depth), do: {2, 0}

  def get_fault_location(depth) when depth == 0, do: {0, 3}

  def get_fault_location(_depth), do: {0, 0}

  def get_target(target, depth) when depth == 0, do: Map.get(@num_loc_map, target)

  def get_target(target, _depth), do: Map.get(@dir_loc_map, target)

  def part_two(problem) do
    :ets.new(:steps_cache, [:named_table, :public, :set, :protected])

    target_digits =
      Enum.map(problem, fn digits ->
        Enum.filter(digits, &(&1 not in ["A"]))
        |> Enum.join()
        |> String.to_integer()
      end)

    result =
      Enum.map(problem, &calculate_number_steps(&1, 26, 0))
      |> Enum.zip(target_digits)
      |> Enum.map(fn {steps, target} -> steps * target end)
      |> Enum.sum()

    :ets.delete(:steps_cache)
    result
  end
end
