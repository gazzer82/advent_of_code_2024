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

  defmemo rule(stone) do
    if stone == 0 do
      1
    else
      stone_string = Integer.to_string(stone)
      digits = String.length(Integer.to_string(stone))

      case Integer.is_even(digits) do
        true ->
          String.split_at(stone_string, div(digits, 2))
          {left, right} = String.split_at(stone_string, div(digits, 2))

          [
            String.to_integer(left),
            String.to_integer(right)
          ]

        _ ->
          stone * 2024
      end
    end
  end

  defmemo split_into_chunks(options) do
    workers = :erlang.system_info(:schedulers_online)
    options_count = Enum.count(options)
    options_per_chunk = :erlang.ceil(options_count / workers)

    Enum.chunk_every(options, options_per_chunk)
  end
end
