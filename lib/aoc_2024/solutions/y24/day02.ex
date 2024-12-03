defmodule Aoc2024.Solutions.Y24.Day02 do
  alias AoC.Input

  def parse(input, _part) do
    Input.read!(input)
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split(&1, " ", trim: true))
    |> Enum.map(
      &Enum.map(&1, fn a ->
        String.to_integer(a)
      end)
    )
    |> Enum.map(&maybe_reverse_list/1)
  end

  def part_one(problem) do
    problem
    |> Enum.map(&is_seq_valid?/1)
    |> Enum.filter(& &1)
    |> Enum.count()
  end

  def maybe_reverse_list(list) do
    first = List.first(list)
    last = List.last(list)

    case first < last do
      true -> list
      false -> Enum.reverse(list)
    end
  end

  def is_seq_valid?([first | rest]) do
    is_valid(rest, first)
  end

  def is_valid([], _current) do
    true
  end

  def is_valid([head | rest], current) do
    case head > current && head <= current + 3 do
      true -> is_valid(rest, head)
      false -> false
    end
  end

  def part_two(problem) do
    problem
    |> Enum.map(&make_variants(&1))
    |> Enum.map(&are_any_valid?/1)
    |> Enum.filter(& &1)
    |> Enum.count()
  end

  def are_any_valid?(combos) do
    Enum.any?(combos, fn seq ->
      is_seq_valid?(seq)
    end)
  end

  def make_variants(seq, index \\ 0, acc \\ [])

  def make_variants(seq, index, acc) when index > length(seq) do
    acc
  end

  def make_variants(seq, index, acc) do
    make_variants(seq, index + 1, acc ++ [List.delete_at(seq, index)])
  end
end
