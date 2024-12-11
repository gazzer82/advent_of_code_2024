defmodule Aoc2024.Solutions.Y24.Day11 do
  require Integer
  alias AoC.Input

  def parse(input, _part) do
    Input.read!(input)
    |> String.trim()
    |> String.split(" ", trim: true)
    |> Enum.map(&String.to_integer/1)
  end

  def part_one(problem) do
    :ets.new(:apply_rules_cache, [:named_table, :public, :set, :protected])

    result =
      Enum.reduce(problem, 0, fn stone, acc ->
        acc + apply_rules(stone, 0, 25)
      end)

    :ets.delete(:apply_rules_cache)
    result
  end

  def part_two(problem) do
    :ets.new(:apply_rules_cache, [:named_table, :public, :set, :protected])

    result =
      Enum.reduce(problem, 0, fn stone, acc ->
        acc + apply_rules(stone, 0, 75)
      end)

    :ets.delete(:apply_rules_cache)
    result
  end

  def apply_rules(stone, count, target) do
    case :ets.lookup(:apply_rules_cache, {stone, count, target}) do
      [{_, result}] ->
        result

      [] ->
        result =
          if count == target do
            1
          else
            target_stones = rule(stone)

            case target_stones do
              [_first, _second] ->
                Enum.reduce(target_stones, 0, fn stone, acc ->
                  acc + apply_rules(stone, count + 1, target)
                end)

              stone ->
                apply_rules(stone, count + 1, target)
            end
          end

        :ets.insert(:apply_rules_cache, {{stone, count, target}, result})
        result
    end
  end

  def rule(stone) do
    if stone == 0 do
      1
    else
      stone_length = Integer.digits(stone)
      num_digits = length(stone_length)

      case Integer.is_even(num_digits) do
        true ->
          stone_string = Integer.to_string(stone)
          mid = div(num_digits, 2)
          <<left::binary-size(mid), right::binary>> = stone_string
          [String.to_integer(left), String.to_integer(right)]

        _ ->
          stone * 2024
      end
    end
  end
end
