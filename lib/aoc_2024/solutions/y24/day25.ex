defmodule Aoc2024.Solutions.Y24.Day25 do
  alias AoC.Input

  def parse(input, _part) do
    Input.read!(input)
    |> String.split("\n\n", trim: true)
    |> Enum.map(&String.split(&1, "\n", trim: true))
    |> Enum.split_with(fn [first | _] -> first == "#####" end)
  end

  def part_one({locks, keys}) do
    locks =
      rotate(locks)

    keys = rotate(keys)
    how_many_fit(keys, locks)
  end

  def rotate(matrix) do
    matrix
    |> Enum.map(fn key ->
      Enum.map(key, fn row ->
        String.graphemes(row)
      end)
      |> Enum.zip()
      |> Enum.map(fn rows ->
        Tuple.to_list(rows)
        |> Enum.filter(fn char -> char == "#" end)
        |> Enum.join()
        |> String.length()
      end)
    end)
  end

  def how_many_fit(keys, locks) do
    keys
    |> Enum.reduce(0, fn [key_1, key_2, key_3, key_4, key_5], acc ->
      Enum.reduce(locks, acc, fn [lock_1, lock_2, lock_3, lock_4, lock_5], acc ->
        if key_1 + lock_1 <= 7 and key_2 + lock_2 <= 7 and key_3 + lock_3 <= 7 and
             key_4 + lock_4 <= 7 and key_5 + lock_5 <= 7 do
          acc + 1
        else
          acc
        end
      end)
    end)
  end

  # def part_two(problem) do
  #   problem
  # end
end
