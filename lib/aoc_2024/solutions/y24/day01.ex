defmodule Aoc2024.Solutions.Y24.Day01 do
  alias AoC.Input

  use Memoized

  def parse(input, _part) do
    Input.read!(input)
    |> String.split("\n", trim: true)
  end

  def part_one(problem) do
    problem
    |> Enum.map(&String.split(&1, " ", trim: true))
    |> Enum.map(fn [a, b] -> {String.to_integer(a), String.to_integer(b)} end)
    |> Enum.unzip()
    |> sort_zip_lists()
    |> Enum.map(&find_diff/1)
    |> Enum.sum()
  end

  def find_diff({a, b}), do: abs(b - a)

  def sort_zip_lists({a, b}) do
    Enum.zip(Enum.sort(a), Enum.sort(b))
  end

  def part_two(problem) do
    {list1, list2} =
      problem
      |> Enum.map(&String.split(&1, " ", trim: true))
      |> Enum.map(fn [a, b] -> {String.to_integer(a), String.to_integer(b)} end)
      |> Enum.unzip()

    list1
    |> count_occurrences(list2)
    |> Enum.filter(&(&1 != []))
    |> calculate_scores()
    |> Enum.sum()
  end

  def count_occurrences(lista, listb) do
    Enum.map(lista, fn item ->
      Enum.filter(listb, fn x -> x == item end)
    end)
  end

  def calculate_scores(list) do
    Enum.map(list, fn x ->
      [number | _] = x
      number * length(x)
    end)
  end
end
