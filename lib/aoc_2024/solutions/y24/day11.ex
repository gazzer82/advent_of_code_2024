defmodule Aoc2024.Solutions.Y24.Day11 do
  require Integer
  alias AoC.Input

  use Memoize

  def parse(input, _part) do
    Input.read!(input)
    |> String.trim()
    |> String.split(" ", trim: true)
    |> Enum.map(&String.to_integer/1)
  end

  def part_one(problem) do
    Enum.reduce(problem, 0, fn stone, acc ->
      acc + apply_rules(stone, 0, 25)
    end)
  end

  def part_two(problem) do
    Enum.reduce(problem, 0, fn stone, acc ->
      acc + apply_rules(stone, 0, 75)
    end)
  end

  defmemo apply_rules(stone, count, target) do
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
  end

  def rule(stone) do
    if stone == 0 do
      1
    else
      stone_string = Integer.to_string(stone)
      digits = byte_size(stone_string)

      case Integer.is_even(digits) do
        true ->
          mid = div(digits, 2)
          <<left::binary-size(mid), right::binary>> = stone_string
          [String.to_integer(left), String.to_integer(right)]

        _ ->
          stone * 2024
      end
    end
  end
end
