defmodule Aoc2024.Solutions.Y24.Day03 do
  alias AoC.Input

  def parse(input, _part) do
    Input.read!(input)
  end

  def part_one(problem) do
    Regex.scan(~r/mul\((\d{1,3}),(\d{1,3})\)/, problem)
    |> Enum.map(fn [_, a, b] ->
      String.to_integer(a) * String.to_integer(b)
    end)
    |> Enum.sum()
  end

  def part_two(problem) do
    problem = "do()" <> String.replace(problem, "\n", "") <> "don't()"

    Regex.scan(~r/do\(\).*?don't\(\)/, problem)
    |> Enum.flat_map(fn input ->
      input |> Enum.map(&part_one/1)
    end)
    |> Enum.sum()
  end
end
