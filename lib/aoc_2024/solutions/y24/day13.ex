defmodule Aoc2024.Solutions.Y24.Day13 do
  alias AoC.Input

  def parse(input, _part) do
    Input.read!(input)
    |> String.split("\n", trim: true)
    |> Enum.chunk_every(3)
    |> Enum.map(fn line ->
      [button_a, button_b, prize] = line
      {get_x_y(button_a), get_x_y(button_b), get_x_y(prize)}
    end)
  end

  def get_x_y(button) do
    button
    |> String.split(": ")
    |> List.last()
    |> String.split(", ")
    |> Enum.map(fn str ->
      str
      |> String.split(["=", "+"])
      |> List.last()
      |> String.to_integer()
    end)
    |> List.to_tuple()
  end

  def part_one(problem) do
    solve(problem, 0)
  end

  def part_two(problem) do
    solve(problem, 10_000_000_000_000)
  end

  def solve(problem, multi) do
    problem
    |> Enum.reduce(0, fn {{a_x, a_y}, {b_x, b_y}, {prize_x, prize_y}}, acc ->
      moves_a = div(b_y * (prize_x + multi) - b_x * (prize_y + multi), b_y * a_x - b_x * a_y)
      moves_b = div(a_y * (prize_x + multi) - a_x * (prize_y + multi), a_y * b_x - a_x * b_y)

      pos_x = moves_a * a_x + moves_b * b_x
      pos_y = moves_a * a_y + moves_b * b_y

      if pos_x == prize_x + multi and pos_y == prize_y + multi do
        acc + 3 * moves_a + moves_b
      else
        acc
      end
    end)
  end
end
